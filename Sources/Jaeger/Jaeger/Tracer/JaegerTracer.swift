//
//  JaegerTracer.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 11/7/18.
//

import Foundation

/// A tracer for Jaeger spans.
public typealias JaegerTracer = BasicTracer

/// A tracer using a generic agent for the caching process.
public final class BasicTracer: Tracer {

    /// A fixed id for the tracer.
    let tracerId = UUID()
    /// The agent used for the caching process.
    private let agent: Agent

    /**
     Creates a new tracer with a unique identifier.
     
     - Parameter agent: The agent used for the caching process.
     */
    init(agent: Agent) {
        self.agent = agent
    }

    /**
     A point of entry the crete a start a new span wrapped in an OTSpan.
     
     - Parameter operationName: A human-readable string which concisely represents the work done by the Span. See [OpenTracing Semantic Specification](https://opentracing.io/specification/) for the naming conventions.
     - Parameter referencing: The relationship to a node (span).
     - Parameter startTime: The time at which the task was started.
     - Parameter tags: Tags to be included at the creation of the span.
     
     - Returns: A new `Span` wrapped in an OTSpan.
     */
    public func startSpan(operationName: String, referencing reference: Span.Reference?, startTime: Date, tags: [Tag]) -> OTSpan {

        let span = Span(
            tracer: self,
            spanRef: .init(traceId: self.tracerId, spanId: UUID()),
            parentSpanRef: reference,
            operationName: operationName,
            flag: .sampled,
            startTime: startTime,
            tags: [:],
            logs: []
        )

        return OTSpan(span: span)
    }

    /**
     Transfer a **completed** span to the tracer.
     
     - Parameter span: A **completed** span.
     */
    public func report(span: Span) {
        self.agent.record(span: span)
    }
}
