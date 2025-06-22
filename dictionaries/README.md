# ドメイン知識ディレクトリ

各workerが作業時に参照できる専門知識やドメイン情報を格納するディレクトリです。

## 使用方法

各workerの指示書で以下のように参照を指定できます：

```markdown
## 参照すべき知識
- @dictionaries/technical_terms.yaml
- @dictionaries/business_rules.json
- @dictionaries/api_specifications.md
```

## ファイル形式例

### YAML形式 (用語集)
```yaml
# technical_terms.yaml
terms:
  API: "Application Programming Interface"
  REST: "Representational State Transfer"
  
categories:
  web:
    - HTTP
    - HTTPS
    - JSON
```

### JSON形式 (構造化データ)
```json
{
  "businessRules": {
    "validation": {
      "email": "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$",
      "phone": "^\\d{3}-\\d{4}-\\d{4}$"
    }
  }
}
```

### Markdown形式 (文書)
```markdown
# API仕様書
## エンドポイント一覧
- GET /api/users
- POST /api/users
```

## 推奨ファイル名

- `technical_terms.yaml` - 技術用語集
- `business_rules.json` - ビジネスルール
- `api_specifications.md` - API仕様
- `coding_standards.md` - コーディング規約
- `project_glossary.yaml` - プロジェクト用語集