# animal-animation-pipeline

## ⚠️ 歯止めルール
**やりたくなったことは即 `ideas/backlog.md` に書いてから今週のタスクに戻る。**
Month4最終週まで実装しない。これが唯一のルール。

---

## プロジェクト概要
動物（犬・馬）の動画を入力すると、リアルなアニメーションJSONを自動生成し
Flutterアプリで表示するパイプラインを構築する。

## 最終ゴール
```
動物の動画 → Python（ポーズ推定） → JSON自動生成 → Flutter表示
```

## 技術スタック
| 領域 | 技術 |
|------|------|
| フロントエンド | Flutter（Mac / VS Code） |
| ポーズ推定 | Python / MediaPipe / DeepLabCut |
| コード管理 | GitHub |

## リアルさ3指標（縦積み方式）
| 指標 | 上限 | 達成月 |
|------|------|--------|
| ① フレーム数 | 60fps | Month1 |
| ② 関節数 | 16個 | Month2 |
| ③ 物理ルール数 | 7個 | Month3 |

1つの指標を100%にしてから次へ進む。

## フォルダ構成
```
├── src/         Flutterコード
├── pipeline/    Pythonコード
├── docs/        技術ノート
├── ideas/       アイデア封印リスト
└── README.md
```
```

---

## Step 4: .gitignore を作成

ルートに `.gitignore` ファイルを作成して以下を貼り付けます。
```
# Flutter
**/android/.gradle
**/android/captures/
**/android/local.properties
**/.dart_tool/
**/.flutter-plugins
**/.flutter-plugins-dependencies
**/build/
**.iml

# Python
__pycache__/
*.py[cod]
.venv/
*.egg-info/
.DS_Store

# VS Code
.vscode/