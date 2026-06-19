//
//  BodyMetric.swift
//  fitnote
//
//  Created by Antigravity on 2026/06/18.
//

import Foundation
import SwiftData

/// 身体測定データ（体重、体脂肪率）を記録するモデル。
@Model
final class BodyMetric {
    /// 測定した日時
    var date: Date
    
    /// 体重 (kg)
    var weight: Double
    
    /// 体脂肪率 (%)。入力は任意。
    var bodyFat: Double?
    
    init(date: Date = Date(), weight: Double, bodyFat: Double? = nil) {
        self.date = date
        self.weight = weight
        self.bodyFat = bodyFat
    }
}
