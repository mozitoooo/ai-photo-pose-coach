import Vision
import AVFoundation
import UIKit

final class PoseDetector {
    private let requestHandler = VNSequenceRequestHandler()
    
    struct PoseSuggestion {
        let bodyPart: String
        let suggestion: String
        let confidence: Float
    }
    
    func detect(in pixelBuffer: CVPixelBuffer, completion: @escaping ([PoseSuggestion]) -> Void) {
        let request = VNDetectHumanBodyPoseRequest { request, error in
            guard let observations = request.results as? [VNHumanBodyPoseObservation],
                  let pose = observations.first else {
                completion([])
                return
            }
            let suggestions = self.analyzePose(pose)
            DispatchQueue.main.async { completion(suggestions) }
        }
        try? requestHandler.perform([request], on: pixelBuffer)
    }
    
    private func analyzePose(_ pose: VNHumanBodyPoseObservation) -> [PoseSuggestion] {
        var suggestions: [PoseSuggestion] = []
        
        // Analyze shoulder alignment
        if let leftShoulder = try? pose.recognizedPoint(.leftShoulder),
           let rightShoulder = try? pose.recognizedPoint(.rightShoulder),
           leftShoulder.confidence > 0.5, rightShoulder.confidence > 0.5 {
            let tilt = abs(leftShoulder.location.y - rightShoulder.location.y)
            if tilt > 0.05 {
                suggestions.append(PoseSuggestion(
                    bodyPart: "Shoulders",
                    suggestion: "Level your shoulders for a more balanced look",
                    confidence: min(leftShoulder.confidence, rightShoulder.confidence)
                ))
            }
        }
        
        // Analyze neck/head position
        if let nose = try? pose.recognizedPoint(.nose),
           let neck = try? pose.recognizedPoint(.neck),
           nose.confidence > 0.5, neck.confidence > 0.5 {
            let forwardTilt = nose.location.x - neck.location.x
            if abs(forwardTilt) > 0.04 {
                suggestions.append(PoseSuggestion(
                    bodyPart: "Head",
                    suggestion: "Tuck your chin slightly and elongate your neck",
                    confidence: nose.confidence
                ))
            }
        }
        
        return suggestions
    }
}
