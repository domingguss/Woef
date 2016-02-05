import AVFoundation

@objc public protocol RecorderDelegate: AVAudioRecorderDelegate {
    optional func audioMeterDidUpdate(dB: Float)
}

public class RecorderService : NSObject {
    
    static let sharedInstance = RecorderService(to: "record")
    
    public var delegate: RecorderDelegate!
    
    let session = AVAudioSession.sharedInstance()
    var recorder: AVAudioRecorder!
    var player: AVAudioPlayer!
    var url: NSURL!
    
    var bitRate = 64000
    var sampleRate = 44100.0
    var channels = 1
    
    var metering: Bool {
        return delegate.respondsToSelector("audioMeterDidUpdate:")
    }
    
    var directory: NSString {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    }
    
    private var link: CADisplayLink?
    
    public init(to: NSString)
    {
        super.init()
    }
    
    public func recordToFile(fileURL: NSURL)
    {
        url = fileURL
        let options: Dictionary = [
            AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatAppleLossless),
            AVEncoderAudioQualityKey: NSNumber(integer: AVAudioQuality.Medium.rawValue),
            AVEncoderBitRateKey: bitRate,
            AVNumberOfChannelsKey: channels,
            AVSampleRateKey: sampleRate
        ]
        
        do {
            try recorder = AVAudioRecorder(URL: fileURL, settings:options)
            
            recorder.prepareToRecord()
            
            recorder.delegate = delegate
            recorder.meteringEnabled = metering
            
            if metering {
                startMetering()
            }
            
            try session.setCategory(AVAudioSessionCategoryRecord)
        
            recorder.record()
        } catch let error as NSError {
            print(error)
        }
    }
    
    public func stop()
    {
        do {
            recorder.stop()
            
            try session.setCategory(AVAudioSessionCategoryPlayback, withOptions: .MixWithOthers)
            
            if metering {
                stopMetering()
            }
            
        } catch let error as NSError {
            print(error);
        }
    }
    
    public func updateMeter()
    {
        recorder.updateMeters()
        
        let dB = recorder.averagePowerForChannel(0)
        
        delegate.audioMeterDidUpdate?(dB)
    }
    
    private func startMetering()
    {
        link = CADisplayLink(target: self, selector: "updateMeter")
        link?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    private func stopMetering()
    {
        link?.invalidate()
    }
    
}
