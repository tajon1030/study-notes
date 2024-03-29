# SSL/TLS

현재 작업중인 서비스에서 외부 api 호출시 `ssl handshake exception:pkix path building failed` 오류가 발생하는 문제를 겪었습니다.  
외부 api에서 SSL인증서를 갱신하면서 생긴 문제였는데,  
api를 호출하는쪽에서 외부서버의 SSL인증서를 갱신했다고 Exception이 터진다는 것을 이해할 수가 없었습니다.  
사내에서 도움을 받아 문제를 해결했지만 용어부터 모르는 것들이 많아 해당 내용들을 전부 이해할수가 없어서 따로 공부하고 정리를 해보았습니다.  

## 초보자도 알기쉬운 SSL/TLS 인증 설명  
SSL(Secure Sockets Layer)은 웹서버와 클라이언트간의 통신을 암호화하고 보안을 강화하기 위한 프로토콜입니다.  
SSL은 TLS(Transport Layer Security)라고도 불립니다.(표준화기구 IETF의 관리로인한 명칭 변경)  
SSL/TLS는 주로 웹 서버와 브라우저간의 통신에서 사용되며 데이터의 안전한 전송을 보장합니다.  

## 중요한 SSL/TLS 용어1
- 대칭키 암호화 : 암복호화에 동일한 키를 사용하는 암호화 알고리즘입니다.(DES/AES/3DES)  
- 개인키 : **서버**에 저장되는 **비밀키**입니다.  
- 공개키 : 공개될수있는 키입니다.  
- 비대칭키(공개키) 암호화 : 두개의 서로 다른 키를 사용하여 암호화와 복호화를 수행하는 알고리즘입니다.  
키쌍중 하나는 공개키이고, 하나는 개인키이며,  
공개키로 암호화되었다면 개인키로만,  
개인키로 암호화되었다면 공개키로만 해독이 가능합니다.  

## SSL/TLS 프로토콜의 기본 동작 방식
SSL/TLS 프로토콜은 대칭키와 비대칭키 암호화를 혼합하여 사용합니다.  
1. Handshake  
클라이언트와 서버간 연결이 이루어지기 전에 핸드셰이크가 시작되어, 클라이언트가 서버에게 자신의 지원가능한 암호화 알고리즘 목록을 전달합니다.  
2. 서버인증과 공개키 교환  
서버는 클라이언트에게 서버인증서를 제공합니다. 여기에는 공개키가 포함되어있어서  
클라이언트는 서버의 공개키를 통해 대칭키로 사용될 값(pre-master secret)을 서버에게 암호화하여 전송합니다.  
3. 대칭키 암호화  
서버는 개인키를 사용하여 pre-master secret을 복호화하고,  
양측은 pre-master secret을 기반으로 대칭키를 생성하여 향후 주고받을 데이터를 암복호화할때 사용합니다.  
4. 암호화된 통신  
대칭키를 사용하여 클라이언트와 서버간 안전한 데이터 통신이 이루어집니다.  

즉, 핸드셰이크 단계에서는 공개키를 사용하여 대칭키를 교환하고, 이후 실제 데이터를 주고받을때 대칭키를 사용하여 암복호화합니다.  

## SSL/TLS 인증서를 발급받기위한 절차
1. 개인키 생성:
먼저 서버에서 `openssl` 등의 툴을 사용하여 **개인키**를 생성합니다.  
`openssl genrsa -des3 -out private-key.pem 2048`  

2. CSR 생성:  
생성된 개인키를 사용하여 **CSR**을 생성합니다.  
**CSR**은 **SSL발급 요청서**라고도 하며,  
SSL 인증서를 발급받기위해 필요한 정보를 담은 요청서라고 보면 되겠습니다.  
CSR에는 서버의 정보와 공개키가 포함됩니다.  
`openssl req -new -key private-key.pem -out csr.pem`

2. CSR 제출:  
CSR을 **CA**라고하는 신뢰할수있는 제 3의 **인증 기관에 제출**합니다.  

3. 인증서 발급:  
CA는 CSR을 검토하고, 요청한 도메인의 소유자임을 확인한 후, **서버 인증서, 루트인증서, 체인인증서를 발급**합니다.  

4. 서버 설정:  
개인키파일과 발급받은 SSL인증서 파일들을 서버에 준비한뒤 웹서버설정파일(ex Apache의 httpd.conf)를 수정하여 SSL설정을 추가한뒤 재시작을 통해 변경사항을 적용합니다.  
~~~conf  
SSLCertificateFile /path/to/server.crt   # 서버 인증서 파일
SSLCertificateKeyFile /path/to/private.key   # 개인키 파일
SSLCertificateChainFile /path/to/sub.class1.server.ca.pem # 체인(중개) 인증서 파일
SSLCACertificateFile /path/to/ca.pem   # 루트 인증서 파일
~~~  
적용후 서버는 발급받은 서버인증서를 클라이언트에게 제공합니다.  
클라이언트는 공개키를 사용해서 서버인증서를 검증하며,  
서버는 클라이언트가 공개키로 암호화한 대칭키를 개인키를 사용하여 복호화함으로서 안전한 통신을 설정합니다.  


## 중요한 SSL/TLS 용어2  
- **CSR** : **인증서 발급을 요청**하기위한 데이터  
(서버의 공개키+도메인,조직 등 주체정보+유효성을 검증하기위한 서명알고리즘정보)  
- **서버인증서** : CA에 의해 서명된 데이터를 담은 **디지털 인증서**    
서버의 신원을 검증하는데 사용됩니다.  
일반적으로 **도메인정보, 공개키, 서명 등**이 포함되어있습니다.  
(서버의 공개키+도메인,조직 등 주체정보+유효성을 검증하기위한 서명알고리즘정보)
- **루트 인증서** : CA에서 발급하는 가장 상위의 디지털 인증서로,  **최상위 인증서**입니다.  
클라이언트는 루트인증서를 사용하여 서버로부터 수신한 인증서의 유효성을 검증합니다.  
인증서에는 해당 CA에서 발행한 디지털 인증서의 서명을 검증가능한 공개키/ CA의 신원정보-이름,조직정보,국가 등 / 루트인증서의 유효기간 / 해당 CA가 사용하는 암호화방식인 서명알고리즘 / 다른 디지털 인증서와의 신뢰경로 / 확장필드-추가정보,정책,사용목적등 을 포함합니다.  
- **체인 인증서** : 루트CA가 발행한 것이 아니라, 루트 CA의 인증서의 중간단계에서 발급된 인증서입니다.  
중간 CA가 서명한 서버인증서는 클라이언트에게 전송되고 클라이언트는 중간 CA의 공개키를 사용하여 서버인증서의 서명을 확인합니다.  
체인인증서는 루트CA와 서버인증서간의 중간계층 역할을 합니다.  

## 서버에서 클라이언트로의 SSL/TLS 통신의 흐름  
1. 서버는 서버인증서를 제공합니다.  
2. 클라이언트는 서버인증서의 유효성을 확인하기위해 루트인증서와 체인인증서를 사용합니다.  
3. 클라이언트는 루트인증서가 신뢰할 수 있는지 확인하고, 체인인증서를 사용하여 서버인증서의 서명을 확인합니다.  
4. 클라이언트가 서버인증서를 신뢰하면 안전한 통신이 시작됩니다.  

## SSL handshake exception: PKIX path building failed
여기까지 알아봤을때 '아니 그래서 이 오류가 왜 발생한건데?' 라는 생각이 들것입니다.  
여태껏 외부 api들을 호출하면서 SSL인증서가 만료되었는지 정도만 신경을 써왔고 인증서를 갱신했다는 이유로 오류가 발생되는 경험은 해본적이 없기때문입니다.  
따라서 해당 오류에 대해 알아보도록 합니다.  
해당 오류는 SSL/TLS 연결에서 발생하는 문제로, 주로 다음과 같은 이유로 발생할 수 있습니다.  
1. 서버측 원인 : 
웹서버에 SSL 인증서 설치 적용시 '루트/체인(중개)' 을 누락하고 '서버인증서' 만 적용했기 때문입니다. (CSR 직접 생성 후, jks 파일을 직접 생성,조합 과정에서 루트/체인 포함 누락)

2. 클라이언트 원인 :
서버 SSL 인증서 발급자(루트/체인) 정보가 Client 에 없을때도 발생합니다.  (매우 오래된 Java 버전에서도 발생 > Java 버전 업그레이드) (Java Client 에 루트/체인 수동 추가 필요)

## CA승인서의 갱신  
현재 운영중인 서비스는 매우 오래된 Java버전기반의 Server To Server 방식을 사용하고있기때문에, 루트인증서가 업데이트되었는지를 확인해볼 필요가 있었습니다.  
확인결과 Root/Chain 인증서가 변경되었고 보통의 경우 Windows및 최신브라우저에 신뢰할수있는 상태로 포함되어있기때문에 추가조치할 필요가 없으나, 우리는 Server to Server API 통신을 하며 요청하는 서버의 Java 버전이 최소호환버전(jre1.8.0_131+)보다 낮은경우(jre1.7.0)에 속해 직접 Java cacerts에 루트인증서를 추가해야 했습니다.  
(일반적으로 **웹브라우저는 내장된 CA리스트를 가지고있어서 웹에서는 브라우저 등이 자동으로 CA 승인서를 업데이트**하고, 사용자는 이러한 프로세스를 크게 인식하지 않아도 됩니다.)  

[DigiCert SSL인증서 루트/체인 업데이트 2023.03.08실행](https://cert.crosscert.com/%ec%a4%91%ec%9a%94%ea%b3%b5%ec%a7%80-digicert-ssl%ec%9d%b8%ec%a6%9d%ec%84%9c-%eb%a3%a8%ed%8a%b8-%ec%b2%b4%ec%9d%b8-%ec%97%85%eb%8d%b0%ec%9d%b4%ed%8a%b8-2023-03-08%ec%8b%a4%ed%96%89/)

## cacerts에 루트/체인 인증서 추가하기  
**cacerts**는 Java에서 사용되는 **기본키저장소(keystore)** 중 하나로 시스템에 설치된 **SSL/TLS 인증서의 신뢰여부를 결정하는 파일**입니다.  
보통 이 파일은 JRE또는 JDK와 함께 제공됩니다.  
HTTPS를 사용하는 경우, 클라이언트가 서버로부터 수신한 SSL/TLS인증서의 체인에 포함된 **루트인증서가 cacerts에 등록되어있어야**합니다.  

인증서가 적용되어있나 먼저 확인해보기위해서는 자바가 설치된 위치의 security폴더에서 다음 명령어를 실행해보면 됩니다.  
~~~
경로 예: $JAVA_HOME/lib/security:>
명령어: keytool -keystore cacerts -list -v | grep DigiCert
~~~

이어서 인증서를 추가하기위해서는 `keytool`이라는 명령어를 사용하여 다운로드한 인증서를 cacerts에 추가해야합니다.  
`keytool -import -alias myAlias -keystore cacerts -file /path/to/DigiCert_Global_Root_G2.crt`  
(위 명령어에서 myAlias는 인증서에 부여할 별칭입니다.)  

### keytool
keytool: Java Key and Certificate Management Tool로, Java의 키 및 인증서 관리에 사용되는 유틸리티  

## 참고: 인증서/키파일 확장자
인증서와 키에 사용하는 확장자를 평소에 접할 기회가 거의 없었기때문에 확장자를 보면서 이게 무슨파일인지 알아보기가 어려웠습니다.  
루트 인증서와 SSL/TLS 인증서는 직접적으로 식별할 수 없으나 일반적으로 사용되는 표준확장자들은 있습니다.  
- 루트인증서: '.crt','.cer','.pem' 등  
- SSL/TLS 인증서: '.crt', '.cer', '.pem',  '.der', '.p12' 등  
그러나 해당 확장자가 절대적규칙은 아니며 실제로는 파일내용의 형식(루트인증서:공개키인증서형식,SSL/TLS인증서:X.509표준)이 중요합니다.  

또한, 일반적으로는 '.key' 확장자가 개인키파일을 나타내는데 자주 사용되지만 주로 사용되는 툴이나 라이브러리에따라 다르며 환경에따라 적절한 확장자를 선택하는것이 일반적입니다.    
- 개인키: '.key', '.pem', '.p8' 등  


### 확장자
- .pem  
PEM (Privacy Enhanced Mail)은 Base64 인코딩된 ASCII 텍스트  
파일 구분 확장자로 .pem 을 주로 사용  
노트패드에서 열기/수정도 가능하다. 개인키, 서버인증서, 루트인증서, 체인인증서 및  SSL 발급 요청시 생성하는 CSR 등에 사용되는 포맷이며, 가장 광범위하고 거의 99% 대부분의 시스템에 호환되는 산업 표준 포맷이다. (대부분 텍스트 파일)

- .crt  
거의 대부분 PEM 포맷이며, 주로 유닉스/리눅스 기반 시스템에서 인증서 파일임을 구분하기 위해서 사용되는 확장자  
다른 확장자로 .cer 도 사용된다.  
파일을 노트패드 등으로 바로 열어 보면 PEM 포맷인지 바이너리 포맷인지 알수 있지만 99% 는 Base64 PEM 포맷이라고 봐도 무방하다. (대부분 텍스트 파일)

- .cer  
거의 대부분 PEM 포맷이며, 주로 Windows 기반에서 인증서 파일임을 구분하기 위해서 사용되는 확장자  
crt 확장자와 거의 동일한 의미이며, cer 이나 crt 확장자 모두 윈도우에서는 기본 인식되는 확장자이다.  
저장할때 어떤 포맷으로 했는지에 따라 다르며, 이름 붙이기 나름이다.

- .csr  
Certificate Signing Request 의 약자이며 거의 대부분 PEM 포맷이다. SSL 발급 신청을 위해서 본 파일 내용을 인증기관 CA 에 제출하는 요청서 파일임을 구분하기 위해서 붙이는 확장자 이다. (대부분 텍스트 파일)  

- .der  
Distinguished Encoding Representation (DER) 의 약자이며, 바이너리 포맷이다. 노트패드등으로 열어 봐서는 알아 볼수 없다.  
바이너리 인코딩 포맷을 읽을수 있는 인증서 라이브러리를 통해서만 내용 확인이 가능하다.  
사설 또는 금융등 특수 분야 및 아주 오래된 구형 시스템을 제외하고는, 최근 웹서버 SSL 작동 시스템 에서는 흔히 사용되는 포맷은 아니다. (바이너리 이진 파일)

- .pfx / .p12  
PKCS#12 바이너리 포맷이며, Personal Information Exchange Format 를 의미한다.  
주로 Windows IIS 기반에서  인증서 적용/이동시 활용된다. 주요 장점으로는 개인키,서버인증서,루트인증서,체인인증서를 모두 담을수 있어서 SSL 인증서 적용이나 또는 이전시 상당히 유용하고 편리하다.  
Tomcat 등 요즘에는 pfx 설정을 지원하는 서버가 많아지고 있다.  (바이너리 이진 파일)  

- .jks  
Java Key Store 의 약자이며, Java 기반의 독자 인증서 바이너리 포맷이다.  
pfx 와 마찬가지로 개인키,서버인증서,루트인증서,체인인증서를 모두 담을수 있어서 SSL 인증서 파일 관리시 유용하다.  
Tomcat 에서 SSL 적용시 가장 많이 사용되는 포맷이다. (바이너리 이진 파일)  

- .key  
주로 openssl 및 java 에서 개인키 파일임을 구분하기 위해서 사용되는 확장자이다. PEM 포맷일수도 있고 DER 바이너리 포맷일수도 있으며, 파일을 열어봐야 어떤 포맷인지 알수가 있다.  
저장할때 어떤 포맷으로 했는지에 따라 다르며, 확장자는 이름 붙이기 나름이다.  


chatGPT와 https://exhibitlove.tistory.com/28 참고
SpringBoot에서의 적용은 https://tajon1030.github.io/2023-06-12-303potenday/
