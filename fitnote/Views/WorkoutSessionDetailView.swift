//
//  WorkoutSessionDetailView.swift
//  fitnote
//
//  Created by Antigravity on 2026/06/18.
//

import SwiftUI
import SwiftData

struct WorkoutSessionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var session: WorkoutSession
    
    @State private var showingAddExercise = false
    @FocusState private var isNoteFocused: Bool
    
    // 日付フォーマッター
    private var sessionDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: session.date)
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        // メモ入力エリア（インラインで編集可能）
                        VStack(alignment: .leading, spacing: 8) {
                            Text("トレーニングメモ")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            
                            TextField("調子や意識したことなどを記入...", text: $session.note, axis: .vertical)
                                .lineLimit(1...4)
                                .focused($isNoteFocused)
                                .padding()
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // 種目リストセクション
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("実施した種目")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Spacer()
                                
                                Button(action: {
                                    showingAddExercise = true
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("種目を追加")
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.orange)
                                }
                            }
                            .padding(.horizontal, 8)
                            
                            if session.exercises.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "dumbbell")
                                        .font(.system(size: 40))
                                        .foregroundColor(.orange.opacity(0.3))
                                    
                                    Text("種目が登録されていません")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Button(action: {
                                        showingAddExercise = true
                                    }) {
                                        Text("種目を追加する")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color.orange.opacity(0.1))
                                            .foregroundColor(.orange)
                                            .cornerRadius(20)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.01), radius: 4, x: 0, y: 2)
                            } else {
                                ForEach(session.exercises) { exercise in
                                    NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                                        ExerciseCardView(exercise: exercise, onDelete: {
                                            deleteExercise(exercise)
                                        })
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle(sessionDateString)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseSheet(session: session)
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("完了") {
                    isNoteFocused = false
                }
                .foregroundColor(.orange)
            }
        }
    }
    
    private func deleteExercise(_ exercise: WorkoutExercise) {
        withAnimation {
            if let index = session.exercises.firstIndex(where: { $0.id == exercise.id }) {
                session.exercises.remove(at: index)
            }
            modelContext.delete(exercise)
        }
    }
}

/// 種目のサマリーを一覧表示するカードコンポーネント
struct ExerciseCardView: View {
    let exercise: WorkoutExercise
    var onDelete: () -> Void
    
    // セット数および重量・レップ概要の文字列
    private var sortedSets: [WorkoutSet] {
        exercise.sets.sorted { $0.setNumber < $1.setNumber }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(exercise.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(exercise.sets.count) セット")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                
                // 削除ボタン
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red.opacity(0.8))
                        .padding(.leading, 8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if sortedSets.isEmpty {
                Text("セット未記録 (タップして追加)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(sortedSets.prefix(3)) { set in
                        HStack(spacing: 12) {
                            Text("\(set.setNumber)セット目:")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                                .frame(width: 55, alignment: .leading)
                            
                            Text("\(String(format: "%.1f", set.weight)) kg")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 2) {
                                Text("\(set.reps)")
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                                if set.assistedReps > 0 {
                                    Text("+")
                                        .foregroundColor(.secondary)
                                    Text("\(set.assistedReps)")
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                }
                                Text("reps")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                            
                            if let rpe = set.rpe {
                                Text("RPE \(String(format: "%.1f", rpe))")
                                    .font(.system(size: 10))
                                    .fontWeight(.medium)
                                    .foregroundColor(.purple)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.purple.opacity(0.08))
                                    .cornerRadius(6)
                            }
                        }
                    }
                    
                    if sortedSets.count > 3 {
                        Text("他 \(sortedSets.count - 3) セット...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 2)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    return NavigationStack {
        WorkoutSessionDetailView(session: PreviewContainer.container.mainContext.insertedModelsArray(WorkoutSession.self).first!)
    }
    .modelContainer(PreviewContainer.container)
}

// Preview用の便利な拡張。insertedModelsを配列で取得
extension ModelContext {
    func insertedModelsArray<T: PersistentModel>(_ modelType: T.Type) -> [T] {
        let descriptor = FetchDescriptor<T>()
        return (try? fetch(descriptor)) ?? []
    }
}
