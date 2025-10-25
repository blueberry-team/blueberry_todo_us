# Firebase 설정 가이드

## Firestore 보안 규칙 배포

1. Firebase CLI 설치 (이미 설치되어 있으면 스킵):
```bash
npm install -g firebase-tools
```

2. Firebase 로그인:
```bash
firebase login
```

3. Firebase 프로젝트 초기화:
```bash
firebase init firestore
```

4. 기존 `firestore.rules` 파일 사용 선택

5. Firestore 규칙 배포:
```bash
firebase deploy --only firestore:rules
```

## 또는 Firebase 콘솔에서 직접 설정

1. [Firebase 콘솔](https://console.firebase.google.com/) 접속
2. 프로젝트 선택 (todous-22088)
3. **Firestore Database** 메뉴로 이동
4. **규칙** 탭 클릭
5. 다음 규칙 붙여넣기:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // Rooms 컬렉션 - 모든 사용자가 읽기/쓰기 가능 (개발 환경)
    match /rooms/{roomId} {
      allow read, write: if true;
    }

    // Shared Todos 컬렉션 - 모든 사용자가 읽기/쓰기 가능 (개발 환경)
    match /shared_todos/{todoId} {
      allow read, write: if true;
    }

    // Todos 컬렉션 - 모든 사용자가 읽기/쓰기 가능 (개발 환경)
    match /todos/{todoId} {
      allow read, write: if true;
    }
  }
}
```

6. **게시** 버튼 클릭

## 주의사항

⚠️ **현재 규칙은 개발 환경용입니다!**

프로덕션 환경에서는 다음과 같이 적절한 인증 및 권한 검증을 추가해야 합니다:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // 인증된 사용자만 접근 가능
    match /rooms/{roomId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null &&
        resource.data.members.hasAny([request.auth.uid]);
    }

    match /shared_todos/{todoId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 문제 해결

### "The query requires an index" 에러

에러 메시지에 포함된 링크를 클릭하면 자동으로 인덱스가 생성됩니다.

또는 Firebase 콘솔에서:
1. **Firestore Database** > **인덱스** 탭
2. **복합 인덱스 추가** 클릭
3. 컬렉션: `shared_todos`
4. 필드 추가:
   - `roomId` (오름차순)
   - `createdAt` (오름차순)
5. **인덱스 만들기** 클릭

### 권한 거부 에러

위의 보안 규칙이 제대로 배포되었는지 확인하세요.
