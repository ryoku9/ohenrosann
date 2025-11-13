//
//  _8tripApp.swift
//  88trip
//
//  Created by かめいりょう on 2025/09/27.
//

//ここにはアプリ全体で共有したい状態や設定を書くのが基本

import SwiftUI
import SwiftData
//@main　は最初に呼びたいファイルにつける
@main


struct rensyuu6App: App {
    
    @StateObject private var authService = AuthService()
    
    //    //Itemモデルを含むswiftdata用のコンテナのmodelContainer型shredModelContainer変数を作成
    //    var sharedModelContainer: ModelContainer = {
    //
    //        //Schemaはデータベースの設計図。このなかに登録したいデータを記述して永続化をする
    //        let schema = Schema([
    //            Item.self,
    //        ])
    //
    //        //modelconfigurationはコンテナの設定。
    //        let modelConfiguration = ModelConfiguration(schema: schema,  isStoredInMemoryOnly: false)
    //
    //        //modelContainerを作成してreturnする(for: 登録したいデータSchema型変数,cofigurations: [コンテナの設定変数]
    //        do {
    //            return try ModelContainer(for: schema, configurations: [modelConfiguration])
    //
    //            //失敗した時用のcatch
    //        } catch {
    //            fatalError("Could not create ModelContainer: \(error)")
    //        }
    //    }()
    //   //↑
    //    //var sharedModelContainer: ModelContainer = {...}()
    //    //無名関数(クロージャ)の書き方で、
    //    //{...}内に処理を書いて、()を最後に書くことで即時実行することができる
    //
    //    //無名関数は必ずreturnで返り値を指定するルール
    //
    //
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
        }
        //        .modelContainer(sharedModelContainer)
        //modelContainerを作成してこれを記述することで、
        
        //        @Environment(\.modelContext) private var modelContext
        //        @Query var items: [Item]
        
        //        と下層のビューで記述することによっていつでもデータベースにアクセスすることができる
    }
}


//まとめ
//@mainで最初に処理するファイルを決める

//swiftdataを使う場合
//ModelContainer型の変数に
//schemaと、modelConfigurationを設定したmodelContainerを入れる
//(modelContainerを作るときはdo-catch構文でerrorを出すことを忘れずに)
//modelContainer型の変数をwindowgroup関数に
//    .modelContainer(作った変数)
//を記述する


