## A로 B만들기
[프로그래머스 A로 B만들기](https://school.programmers.co.kr/learn/courses/30/lessons/120886)  

## 풀이
~~~java
class Solution {
    public int solution(String before, String after) {
        int[] arr = new int[26];
        for(int i=0;i<before.length();i++){
            arr[before.charAt(i)-'a']++;
            arr[after.charAt(i)-'a']--;
        }
        int answer = 1;
        for(int i=0;i<26;i++){
            if(arr[i] != 0) return 0;
        }
        return answer;
    }
}
~~~


### 문자배열로 만들어서 정렬한다는 아이디어
~~~java
import java.util.Arrays;
class Solution {
    public int solution(String before, String after) {
        char[] a = before.toCharArray();
        char[] b = after.toCharArray();
        Arrays.sort(a);
        Arrays.sort(b);

        return new String(a).equals(new String(b)) ? 1 :0;
    }
}
~~~


### replaceFirst를 활용한 아이디어
~~~java
class Solution {
    public int solution(String before, String after) {
        for(int i = 0; i < before.length(); i++){
            after = after.replaceFirst(before.substring(i,i+1),"");
        }
        return after.length() == 0? 1: 0;
    }
}
~~~