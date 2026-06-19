//
//  WorkoutSession.swift
//  fitnote
//
//  Created by Antigravity on 2026/06/18.
//

import Foundation
import SwiftData

/// 1回のトレーニングセッション（日付とメモ、それに紐づく複数の種目）を表すモデル。
@Model
final class WorkoutSession {
    /// セッションの日時
    var date: Date
    
    /// セッションに関するメモ
    var note: String
    
    /// セッション内で実施した種目のリスト。セッション削除時に種目も連鎖して削除されます。
    @Relationship(deleteRule: .cascade, inverse: \WorkoutExercise.session)
    var exercises: [WorkoutExercise] = []
    
    init(date: Date = Date(), note: String = "") {
        self.date = date
        self.note = note
    }
}
