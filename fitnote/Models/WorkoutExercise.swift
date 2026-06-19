//
//  WorkoutExercise.swift
//  fitnote
//
//  Created by Antigravity on 2026/06/18.
//

import Foundation
import SwiftData

/// 実行したトレーニング種目（例：ベンチプレス）を表すモデル。
@Model
final class WorkoutExercise {
    /// 種目名（例：ベンチプレス、スクワットなど）
    var name: String
    
    /// 紐づくトレーニングセッション
    var session: WorkoutSession?
    
    /// この種目で実行したセットのリスト。種目削除時にセットも連鎖して削除されます。
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.exercise)
    var sets: [WorkoutSet] = []
    
    init(name: String, session: WorkoutSession? = nil) {
        self.name = name
        self.session = session
    }
}
