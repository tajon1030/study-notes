## H-index
[프로그래머스 H-index](https://school.programmers.co.kr/learn/courses/30/lessons/42747)

해당 논문보다 인용횟수가 크거나 같은 논문편수 h  
citations[i]값이 h값보다 크거나 같을 경우 h값을 반환한다.  
처음으로 만족하는 순간이 h-index의 최대값이다.  
~~~java
import java.util.*;
import java.util.stream.*;
class Solution {
    public int solution(int[] citations) {
        Arrays.sort(citations);

        int answer = 0;
        for(int i=0;i<citations.length;i++){
            int h = citations.length - i;
            
            if(citations[i] >= h){
                answer = h;
                break;
            }
        }
        return answer;
    }
}
~~~

### 배열의 정렬
1. Arrays.sort(배열)

2. 배열 -> stream -> 정렬 -> intStream -> 배열
~~~java
int[] citationsDesc = Arrays.stream(citations).boxed()
    .sorted(Collections.reverseOrder())
    .mapToInt(Integer::intValue)
    .toArray();
~~~


3. 배열 -> stream -> List -> Collctions.sort(list) (Arrays.sort불가능)
~~~java
List<Integer> intList= Arrays.stream(citations)       
                    .boxed()
                    .collect(Collectors.toList());
Collections.sort(intList);
~~~


### 다른 풀이
현재 논문의 인용횟수 vs 현재 논문보다 인용횟수가 크거나 같은 논문의 편수  
중 작은값을 h-index로 지정해야 h회이상 인용된 논문편수가 h편 이상이라는 말이 무조건 참이될수 있음  
=> 두 값중 최솟값으로 h-index를 지정하고, 오름차순으로 정렬된 요소들에 차례로 접근해 최댓값을 갱신해나간다.  
~~~java
import java.util.*;

class Solution {
    public int solution(int[] citations) {
        Arrays.sort(citations);

        int max = 0;
        for(int i = citations.length-1; i > -1; i--){
            int min = (int)Math.min(citations[i], citations.length - i);
            if(max < min) max = min;
        }

        return max;
    }
}

~~~