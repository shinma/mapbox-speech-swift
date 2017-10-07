import Foundation

@objc(MBTextType)
public enum TextType: UInt, CustomStringConvertible {
    
    case text
    
    case ssml
    
    public init?(description: String) {
        let type: TextType
        switch description {
        case "text":
            type = .text
        case "ssml":
            type = .ssml
        default:
            return nil
        }
        self.init(rawValue: type.rawValue)
    }
    
    public var description: String {
        switch self {
        case .text:
            return "text"
        case .ssml:
            return "ssml"
        }
    }
}

@objc(MBAudioFormat)
public enum AudioFormat: UInt, CustomStringConvertible {

    case mp3
    
    case oggVorbis
    
    case pcm
    
    public init?(description: String) {
        let format: AudioFormat
        switch description {
        case "mp3":
            format = .mp3
        case "ogg_vorbis":
            format = .oggVorbis
        case "pcm":
            format = .pcm
        default:
            return nil
        }
        self.init(rawValue: format.rawValue)
    }
    
    public var description: String {
        switch self {
        case .mp3:
            return "mp3"
        case .oggVorbis:
            return "ogg_vorbis"
        case .pcm:
            return "pcm"
        }
    }
}

@objc(MBVoiceOptions)
open class VoiceOptions: NSObject, NSSecureCoding {
    
    public init(text: String) {
        self.text = text
    }
    
    public required init?(coder decoder: NSCoder) {
        text = decoder.decodeObject(of: [NSArray.self, NSString.self], forKey: "text") as? String ?? ""
        
        guard let textType = TextType(description: decoder.decodeObject(of: NSString.self, forKey: "textType") as String? ?? "") else {
            return nil
        }
        self.textType = textType
        
        guard let outputFormat = AudioFormat(description: decoder.decodeObject(of: NSString.self, forKey: "outputFormat") as String? ?? "") else {
            return nil
        }
        self.outputFormat = outputFormat
        
        guard let voiceId = VoiceId(description: decoder.decodeObject(of: NSString.self, forKey: "voiceId") as String? ?? "") else {
            return nil
        }
        self.voiceId = voiceId
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(text, forKey: "text")
        coder.encode(textType, forKey: "textType")
        coder.encode(voiceId, forKey: "voiceId")
        coder.encode(outputFormat, forKey: "outputFormat")
    }
    
    /**
     `String` to create audiofile for. Can either be plain text or [`SSML`](https://en.wikipedia.org/wiki/Speech_Synthesis_Markup_Language).
     
     If `SSML` is provided, `TextType` must be `TextType.ssml`.
     */
    open var text: String
    
    
    /**
     Type of text to synthesize.
     
     `SSML` text must be valid `SSML` for request to work.
     */
    open var textType: TextType = .text
    
    
    /**
     Type of voice to use to say text.
     
     Note, `VoiceId` are specific to a `Locale`.
     */
    open var voiceId: VoiceId = .joanna
    
    
    /**
     Audio format for outputted audio file.
     */
    open var outputFormat: AudioFormat = .mp3
    
    /**
     The path of the request URL, not including the hostname or any parameters.
     */
    internal var path: String {
        let disallowedCharacters = (CharacterSet(charactersIn: "\\!*'();:@&=+$,/<>?%#[]\" ").inverted)
        return "voice/v1/speak/\(text.addingPercentEncoding(withAllowedCharacters: disallowedCharacters)!)"
    }
    
    /**
     An array of URL parameters to include in the request URL.
     */
    internal var params: [URLQueryItem] {
        let params: [URLQueryItem] = [
            URLQueryItem(name: "textType", value: String(describing: textType)),
            URLQueryItem(name: "voiceId", value: String(describing: voiceId)),
            URLQueryItem(name: "outputFormat", value: String(describing: outputFormat))
        ]
        
        return params
    }
}