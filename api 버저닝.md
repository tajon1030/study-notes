# api 버저닝

기존 유의적 버전 관리[Semantic Versioning](https://semver.org/lang/ko/)에서  
날짜 기반 버전 관리[Calender Versioning](https://calver.org/)으로 점점 더 많이 채택되고있다.
(토스와 cafe24에서 해당 전략을 사용중)  


## 날짜기반 버저닝이란
버전 번호 대신 날짜(또는 날짜+시간) 를 버전으로 사용하는 방식

## 왜 날짜 기반 버저닝을 쓰는가?
1. 기능 중심이 아니라 "시간" 중심  
"이 API는 2024년 12월 1일에 정의된 것이다"라는 스냅샷 의미를 지님.  
API 사용자가 언제 버전이 바뀌었는지 직관적으로 알 수 있음.


2. 릴리스 주기와 잘 어울림  
SaaS나 플랫폼 제품에서 정기 배포(월간, 분기)를 할 경우,  
날짜 기반 버저닝은 문서/릴리스 관리에 잘 맞아.


3. 버전 충돌/번호 꼬임 방지  
v1, v2 등 숫자 기반은 팀간 조율이 필요하거나 꼬이기 쉬움.  
날짜는 자연스럽고 충돌 가능성 낮음.



## 어떤 프로젝트에 적합할까?  
| 적합한 경우                            | 부적합한 경우                          |
| --------------------------------- | -------------------------------- |
| API 버전 릴리스가 **주기적**인 경우           | 소규모 API 또는 변경이 거의 없는 프로젝트        |
| **비즈니스 요구**에 따라 자주 API 버전이 나뉘는 경우 | 외부 공개 API에서 **버전 숫자 선호**가 명확한 경우 |
| 문서화 자동화/배포 흐름이 있는 프로젝트            | 내부 API만 있는 프로젝트                  |



## 날짜 기반 버전, 보통 어디에 담을까?  
| 방법                  | 예시                                                                                       | 특징                                 |
| ------------------- | ---------------------------------------------------------------------------------------- | ---------------------------------- |
| **HTTP Header**     | `X-API-Version: 2024-05-14` 또는  `Accept: application/vnd.company+json;version=2024-05-14` | 클린한 URL 유지, 클라이언트가 요청 버전 선택 가능     |


### 토스는 날짜를 헤더에 직접 보내지 않는데?
아마 Toss의 API는 "계정별 고정 버전" 방식이기 때문일것으로 추정함

Toss에 외부 서비스가 연동될 때 → 사전에 어떤 버전을 사용할지 등록 또는 설정  
그 뒤로는 별도의 Header나 날짜 전달 없이,  
Toss가 내부적으로 해당 서비스가 어떤 버전으로 연동되었는지 알고 있음.  
즉, 외부 호출은 단순하게 /v1/payment 같은 endpoint만 쓰고,  
Toss 서버는 고객사(또는 API 키) 기준으로 적절한 날짜 버전을 적용함.  



## 백엔드 설계
### 1. 클라이언트는 버전 정보를 Header에 담아 보냄  
~~~
GET /api/users/me
X-API-Version: 2024-05-14
Authorization: Bearer <token>
~~~

혹은 MIME타입 기반  
~~~
Accept: application/vnd.myapp+json; version=2024-05-14
~~~

### 2. 백엔드에서 해야 할 설계  
1. 버전 헤더만 처리  
~~~java
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final VersionedUserService versionedUserService;

    @GetMapping("/me")
    public UserDto me(@RequestHeader(name = "X-API-Version", required = false) String version) {
        return versionedUserService.getMyInfo(version);
    }
}
~~~

2. 서비스 라우터 만들기  
~~~java
@Service
@RequiredArgsConstructor
public class VersionedUserService {

    private final Map<String, UserService> versionMap;

    public UserDto getMyInfo(String version) {
        // null → 최신 버전
        String key = Optional.ofNullable(version)
                             .map(v -> v.replace("-", ""))
                             .orElse("default");

        UserService service = versionMap.getOrDefault(key, versionMap.get("default"));
        return service.getMyInfo();
    }
}
~~~

3. 각 버전별 서비스 구현  
~~~java
public interface UserService {
    UserDto getMyInfo();
}

@Service("default")
public class UserServiceDefault implements UserService {
    public UserDto getMyInfo() {
        return new UserDto("Default 버전");
    }
}

@Service("20240514")
public class UserService20240514 implements UserService {
    public UserDto getMyInfo() {
        return new UserDto("2024-05-14 버전");
    }
}
~~~

4. 버전 매핑 자동 주입  
~~~java
@Configuration
public class VersionedServiceConfig {

    @Bean
    public Map<String, UserService> userServiceVersionMap(List<UserService> services) {
        return services.stream()
                .collect(Collectors.toMap(
                        s -> s.getClass().getAnnotation(Service.class).value(), // "20240514" 같은 이름
                        Function.identity()
                ));
    }
}
~~~


VersionedServiceConfig에서 빈 주입시에 List<UserService>를 스프링이 자동주입


