//
//  WorkoutSet.swift
//  fitnote
//
//  Created by Antigravity on 2026/06/18.
//

import Foundation
import SwiftData

/// トレーニングの各セットの詳細データを記録するモデル。
@Model
final class WorkoutSet {
    /// セット番号 (1から始まる整数)
    var setNumber: Int
    
    /// 重量 (kg)
    var weight: Double
    
    /// 自力で挙上した回数
    var reps: Int
    
    /// 補助者に助けてもらいながら挙上した回数
    var assistedReps: Int
    
    /// 主観的運動強度 (RPE: Rate of Perceived Exertion) 。1.0〜10.0の範囲、入力は任意。
    var rpe: Double?
    
    /// 紐づくトレーニング種目
    var exercise: WorkoutExercise?
    
    init(setNumber: Int, weight: Double, reps: Int, assistedReps: Int, rpe: Double? = nil, exercise: WorkoutExercise? = nil) {
        self.setNumber = setNumber
        self.weight = weight
        self.reps = reps
        self.assistedReps = assistedReps
        self.rpe = rpe
        self.exercise = exercise
    }
}
