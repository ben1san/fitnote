//
//  WorkoutSessionListView.swift
//  fitnote
//
//  Created by Antigravity on 2026/06/18.
//

import SwiftUI
import SwiftData

struct WorkoutSessionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    
    // ナビゲーションパス（新規セッション開始後に自動で詳細に遷移するために使用）
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if sessions.isEmpty {
                        VStack(spacing: 24) {
                            Image(systemName: "dumbbell.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.orange, .orange.opacity(0.5)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .padding(.top, 100)
                            
                            Text("まだ記録がありません")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("最初の筋トレを開始して、自力レップと補助レップを完璧に記録しましょう！")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            Spacer()
                        }
                    } else {
                        List {
                            ForEach(sessions) { session in
                                NavigationLink(value: session) {
                                    SessionRowView(session: session)
                                }
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        deleteSession(session)
                                    } label: {
                                        Label("削除", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                    
                    // 下部のフローティング風「トレーニングを開始」ボタン
                    VStack(spacing: 12) {
                        Button(action: startNewSession) {
                            HStack(spacing: 8) {
                                Image(systemName: "play.fill")
                                    .font(.subheadline)
                                Text("トレーニングを開始")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.orange, .orange.opacity(0.85)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    .padding(.bottom, 24)
                    .background(
                        Color(.systemBackground)
                            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: -4)
                    )
                }
            }
            .navigationTitle("fitnote")
            .navigationDestination(for: WorkoutSession.self) { session in
                WorkoutSessionDetailView(session: session)
            }
        }
    }
    
    /// 新規セッションを開始して詳細画面へ遷移
    private func startNewSession() {
        withAnimation {
            let newSession = WorkoutSession(date: Date(), note: "")
            modelContext.insert(newSession)
            
            // 画面遷移用のパスに追加
            navigationPath.append(newSession)
        }
    }
    
    /// セッションの削除
    private func deleteSession(_ session: WorkoutSession) {
        withAnimation {
            modelContext.delete(session)
        }
    }
}

/// セッション一覧での1レコード用行ビュー
struct SessionRowView: View {
    let session: WorkoutSession
    
    // 日付フォーマッタ
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日(E) HH:mm"
        return formatter.string(from: session.date)
    }
    
    // 実施した種目の概要文字列
    private var exercisesSummary: String {
        guard !session.exercises.isEmpty else { return "種目未登録" }
        let names = session.exercises.map { "\($0.name) (\($0.sets.count)set)" }
        return names.joined(separator: ", ")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(formattedDate)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            
            if !session.note.isEmpty {
                Text(session.note)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
                
                Text(exercisesSummary)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewContainer.container)
}
