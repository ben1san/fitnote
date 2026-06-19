//
//  PreviewContainer.swift
//  fitnote
//
//  Created by Antigravity on 2026/06/18.
//

import Foundation
import SwiftData

/// SwiftUIプレビューで使用するための、サンプルデータがあらかじめ挿入されたメモリ上の ModelContainer。
@MainActor
struct PreviewContainer {
    static let container: ModelContainer = {
        do {
            let schema = Schema([
                WorkoutSession.self,
                WorkoutExercise.self,
                WorkoutSet.self,
                BodyMetric.self
            ])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: schema, configurations: [configuration])
            
            // サンプルデータ: 2日前の脚トレーニングセッション
            let session1 = WorkoutSession(
                date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                note: "脚の日。スクワットで自己ベスト更新を目指す。"
            )
            let squat = WorkoutExercise(name: "スクワット", session: session1)
            let squatSet1 = WorkoutSet(setNumber: 1, weight: 100.0, reps: 8, assistedReps: 0, rpe: 9.0, exercise: squat)
            let squatSet2 = WorkoutSet(setNumber: 2, weight: 100.0, reps: 6, assistedReps: 2, rpe: 10.0, exercise: squat)
            let squatSet3 = WorkoutSet(setNumber: 3, weight: 90.0, reps: 8, assistedReps: 0, rpe: 8.5, exercise: squat)
            
            squat.sets = [squatSet1, squatSet2, squatSet3]
            session1.exercises = [squat]
            
            // サンプルデータ: 本日の胸トレーニングセッション
            let session2 = WorkoutSession(
                date: Date(),
                note: "胸の日。ベンチプレス中心。RPE高め。"
            )
            let benchPress = WorkoutExercise(name: "ベンチプレス", session: session2)
            let benchSet1 = WorkoutSet(setNumber: 1, weight: 80.0, reps: 10, assistedReps: 0, rpe: 9.0, exercise: benchPress)
            let benchSet2 = WorkoutSet(setNumber: 2, weight: 80.0, reps: 8, assistedReps: 1, rpe: 9.5, exercise: benchPress)
            
            benchPress.sets = [benchSet1, benchSet2]
            session2.exercises = [benchPress]
            
            // サンプルデータ: 身体測定記録
            let metric1 = BodyMetric(
                date: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
                weight: 72.5,
                bodyFat: 15.2
            )
            let metric2 = BodyMetric(
                date: Date(),
                weight: 72.1,
                bodyFat: 15.0
            )
            
            // コンテキストへの挿入
            let context = container.mainContext
            context.insert(session1)
            context.insert(session2)
            context.insert(metric1)
            context.insert(metric2)
            
            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }()
}
