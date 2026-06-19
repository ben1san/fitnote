//
//  ExerciseDetailView.swift
//  fitnote
//
//  Created by Antigravity on 2026/06/18.
//

import SwiftUI
import SwiftData

struct ExerciseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var exercise: WorkoutExercise
    
    // RPEの選択肢
    let rpeOptions: [Double?] = [nil, 6.0, 7.0, 8.0, 8.5, 9.0, 9.5, 10.0]
    
    // セット番号順にソートしたセットリスト
    private var sortedSets: [WorkoutSet] {
        exercise.sets.sorted { $0.setNumber < $1.setNumber }
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if sortedSets.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange.opacity(0.4))
                            .padding(.top, 60)
                        
                        Text("セットが登録されていません")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("下の「セットを追加」ボタンを押して、最初のセットを記録しましょう。")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Spacer()
                    }
                } else {
                    // ヘッダーラベル
                    HStack {
                        Text("セット")
                            .frame(width: 45, alignment: .leading)
                        Spacer()
                        Text("重量 (kg)")
                            .frame(width: 80, alignment: .center)
                        Spacer()
                        Text("自力レップ")
                            .frame(width: 80, alignment: .center)
                        Spacer()
                        Text("補助レップ")
                            .frame(width: 80, alignment: .center)
                        Spacer()
                        Text("RPE")
                            .frame(width: 55, alignment: .trailing)
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color(.systemGroupedBackground))
                    
                    List {
                        ForEach(sortedSets) { set in
                            @Bindable var set = set
                            SetRowView(set: set, onDelete: {
                                deleteSet(set)
                            })
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                }
                
                // フッターアクションエリア
                VStack(spacing: 12) {
                    Button(action: addSet) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("セットを追加")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.orange, .orange.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.bottom, 24)
                .background(
                    Color(.systemBackground)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
                )
            }
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    /// セットの追加
    private func addSet() {
        withAnimation {
            let nextNumber = (exercise.sets.map { $0.setNumber }.max() ?? 0) + 1
            
            // 前のセットがある場合はその値をデフォルトとしてコピーする
            let lastSet = sortedSets.last
            let defaultWeight = lastSet?.weight ?? 60.0
            let defaultReps = lastSet?.reps ?? 10
            let defaultAssisted = lastSet?.assistedReps ?? 0
            let defaultRpe = lastSet?.rpe
            
            let newSet = WorkoutSet(
                setNumber: nextNumber,
                weight: defaultWeight,
                reps: defaultReps,
                assistedReps: defaultAssisted,
                rpe: defaultRpe,
                exercise: exercise
            )
            modelContext.insert(newSet)
            exercise.sets.append(newSet)
        }
    }
    
    /// セットの削除
    private func deleteSet(_ set: WorkoutSet) {
        withAnimation {
            // リレーションシップからの削除とコンテキストからの削除
            if let index = exercise.sets.firstIndex(where: { $0.id == set.id }) {
                exercise.sets.remove(at: index)
            }
            modelContext.delete(set)
            
            // セット番号を再割り当て
            reorderSetNumbers()
        }
    }
    
    /// セット番号の再番号付け
    private func reorderSetNumbers() {
        let sorted = sortedSets
        for (index, set) in sorted.enumerated() {
            set.setNumber = index + 1
        }
    }
}

/// 個々のセット編集用カスタム行コンポーネント
struct SetRowView: View {
    @Bindable var set: WorkoutSet
    var onDelete: () -> Void
    
    @FocusState private var isWeightFocused: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            // セット番号と削除ボタン
            HStack(spacing: 4) {
                Button(action: onDelete) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                }
                .buttonStyle(PlainButtonStyle())
                
                Text("\(set.setNumber)")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .frame(width: 18)
            }
            .frame(width: 45, alignment: .leading)
            
            Spacer()
            
            // 重量 (kg) 入力
            VStack(spacing: 4) {
                TextField("0.0", value: $set.weight, format: .number)
                    .keyboardType(.decimalPad)
                    .focused($isWeightFocused)
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .fontWeight(.semibold)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isWeightFocused ? Color.orange : Color.clear, lineWidth: 1)
                    )
                    .frame(width: 80)
            }
            
            Spacer()
            
            // 自力レップ（ステッパー）
            HStack(spacing: 4) {
                Button(action: { if set.reps > 0 { set.reps -= 1 } }) {
                    Image(systemName: "minus")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .frame(width: 24, height: 24)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                
                Text("\(set.reps)")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .frame(width: 22, alignment: .center)
                
                Button(action: { set.reps += 1 }) {
                    Image(systemName: "plus")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .frame(width: 24, height: 24)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(width: 80)
            
            Spacer()
            
            // 補助レップ（ステッパー）
            HStack(spacing: 4) {
                Button(action: { if set.assistedReps > 0 { set.assistedReps -= 1 } }) {
                    Image(systemName: "minus")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .frame(width: 24, height: 24)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                
                Text("\(set.assistedReps)")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .frame(width: 22, alignment: .center)
                
                Button(action: { set.assistedReps += 1 }) {
                    Image(systemName: "plus")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .frame(width: 24, height: 24)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(width: 80)
            
            Spacer()
            
            // RPE セレクター
            Menu {
                Button("設定なし", action: { set.rpe = nil })
                ForEach([6.0, 7.0, 8.0, 8.5, 9.0, 9.5, 10.0], id: \.self) { val in
                    Button(String(format: "%.1f", val), action: { set.rpe = val })
                }
            } label: {
                Text(set.rpe != nil ? String(format: "%.1f", set.rpe!) : "選択")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(set.rpe != nil ? .purple : .secondary)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(set.rpe != nil ? Color.purple.opacity(0.1) : Color(.secondarySystemGroupedBackground))
                    )
            }
            .frame(width: 55, alignment: .trailing)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        // 重量テキストフィールドがフォーカスされたときのキーボードツールバー
        .toolbar {
            if isWeightFocused {
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        Button("-5.0") { set.weight = max(0, set.weight - 5.0) }
                        Button("-2.5") { set.weight = max(0, set.weight - 2.5) }
                        Spacer()
                        Button("+2.5") { set.weight += 2.5 }
                        Button("+5.0") { set.weight += 5.0 }
                        Spacer()
                        Button("完了") {
                            isWeightFocused = false
                        }
                        .fontWeight(.bold)
                    }
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: WorkoutSession.self, WorkoutExercise.self, WorkoutSet.self, BodyMetric.self, configurations: config)
    
    let exercise = WorkoutExercise(name: "ベンチプレス")
    container.mainContext.insert(exercise)
    
    let set1 = WorkoutSet(setNumber: 1, weight: 80.0, reps: 8, assistedReps: 0, rpe: 9.0, exercise: exercise)
    let set2 = WorkoutSet(setNumber: 2, weight: 80.0, reps: 6, assistedReps: 2, rpe: 9.5, exercise: exercise)
    container.mainContext.insert(set1)
    container.mainContext.insert(set2)
    
    exercise.sets = [set1, set2]
    
    return NavigationStack {
        ExerciseDetailView(exercise: exercise)
    }
    .modelContainer(container)
}
