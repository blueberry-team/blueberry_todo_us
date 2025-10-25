import 'dart:math';

/// 랜덤 닉네임 생성 서비스
class NicknameGenerator {
  /// NicknameGenerator 생성자
  const NicknameGenerator();

  static const _adjectives = [
    '귀여운',
    '쌀쌀맞은',
    '활발한',
    '조용한',
    '용감한',
    '수줍은',
    '똑똑한',
    '장난꾸러기',
    '느긋한',
    '민첩한',
    '친절한',
    '씩씩한',
    '포근한',
    '시원한',
    '따뜻한',
    '차가운',
    '밝은',
    '어두운',
    '신비로운',
    '유쾌한',
    '침착한',
    '열정적인',
    '냉정한',
    '다정한',
    '무뚝뚝한',
    '성실한',
    '자유로운',
    '꼼꼼한',
    '대담한',
    '겸손한',
  ];

  static const _animals = [
    '고양이',
    '호랑이',
    '강아지',
    '토끼',
    '여우',
    '곰',
    '판다',
    '코알라',
    '펭귄',
    '햄스터',
    '다람쥐',
    '사자',
    '늑대',
    '치타',
    '표범',
    '기린',
    '코끼리',
    '하마',
    '코뿔소',
    '얼룩말',
    '캥거루',
    '원숭이',
    '침팬지',
    '고릴라',
    '독수리',
    '부엉이',
    '앵무새',
    '까마귀',
    '백조',
    '오리',
  ];

  /// 디바이스 ID를 기반으로 일관된 닉네임을 생성합니다.
  ///
  /// [deviceId] 디바이스 고유 ID
  /// 같은 디바이스 ID는 항상 같은 닉네임을 생성합니다.
  String generateFromDeviceId(String deviceId) {
    // 디바이스 ID를 해시 코드로 변환
    final hash = deviceId.hashCode.abs();

    // 해시 코드를 사용하여 일관된 인덱스 생성
    final adjectiveIndex = hash % _adjectives.length;
    final animalIndex = (hash ~/ _adjectives.length) % _animals.length;

    return '${_adjectives[adjectiveIndex]} ${_animals[animalIndex]}';
  }

  /// 완전히 랜덤한 닉네임을 생성합니다.
  String generateRandom() {
    final random = Random();
    final adjective = _adjectives[random.nextInt(_adjectives.length)];
    final animal = _animals[random.nextInt(_animals.length)];
    return '$adjective $animal';
  }
}
