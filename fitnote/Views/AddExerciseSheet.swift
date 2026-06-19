//
//  AddExerciseSheet.swift
//  fitnote
//
//  Created by Antigravity on 2026/06/18.
//

import SwiftUI
import SwiftData

struct AddExerciseSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let session: WorkoutSession
    
    @State private var exerciseName: String = ""
    
    // クイック選択用の人気種目リスト
    let popularExercises = [
        "ベンチプレス", "インクラインダンベルプレス",
        "スクワット", "レッグプレス",
        "デッドリフト", "ラットプルダウン", "懸垂",
        "ショルダープレス", "サイドレイズ",
        "バーベルカール", "三頭筋プッシュダウン"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // 種目名入力セクション
                        VStack(alignment: .leading, spacing: 8) {
                            Text("種目名")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .padding(.leading, 8)
                            
                            TextField("種目名を入力（例：ベンチプレス）", text: $exerciseName)
                                .padding()
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                        
                        // 人気の種目クイック選択セクション
                        VStack(alignment: .leading, spacing: 12) {
                            Text("よく行う種目")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .padding(.leading, 8)
                            
                            // フレキシブルなグリッド/Flow風のレイアウト
                            FlowLayout(mode: .scrollable, items: popularExercises) { popularName in
                                Button(action: {
                                    exerciseName = popularName
                                }) {
                                    Text(popularName)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(exerciseName == popularName ? Color.orange.opacity(0.15) : Color(.secondarySystemGroupedBackground))
                                        .foregroundColor(exerciseName == popularName ? .orange : .primary)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(exerciseName == popularName ? Color.orange : Color.clear, lineWidth: 1)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("種目を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        saveExercise()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .disabled(exerciseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveExercise() {
        let trimmedName = exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        // WorkoutExerciseを新規作成してセッションに追加
        let newExercise = WorkoutExercise(name: trimmedName, session: session)
        modelContext.insert(newExercise)
        session.exercises.append(newExercise)
        
        dismiss()
    }
}

// 簡易的なFlowLayoutのSwiftUI実装。人気の種目をタグ状に並べるために使用。
struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let mode: FlowMode
    let items: Data
    let content: (Data.Element) -> Content
    
    @State private var totalHeight = CGFloat.zero
    
    enum FlowMode {
        case scrollable
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }
    
    private func generateContent(in g: GeometryProxy) -> some View {
            var width = CGFloat.zero
            var height = CGFloat.zero
            
            return ZStack(alignment: .topLeading) {
                ForEach(Array(self.items.enumerated()), id: \.offset) { index, item in
                    self.content(item)
                        .padding([.horizontal, .vertical], 4)
                        .alignmentGuide(.leading, computeValue: { d in
                            if (abs(width - d.width) > g.size.width) {
                                width = 0
                                height -= d.height
                            }
                            let result = width
                            if index == self.items.count - 1 {
                                width = 0 // last item
                            } else {
                                width -= d.width
                            }
                            return result
                        })
                        .alignmentGuide(.top, computeValue: { d in
                            let result = height
                            if index == self.items.count - 1 {
                                height = 0 // last item
                            }
                            return result
                        })
                }
            }
            .background(viewHeightReader($totalHeight))
        }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: WorkoutSession.self, WorkoutExercise.self, WorkoutSet.self, BodyMetric.self, configurations: config)
    let session = WorkoutSession()
    container.mainContext.insert(session)
    
    return AddExerciseSheet(session: session)
        .modelContainer(container)
}
