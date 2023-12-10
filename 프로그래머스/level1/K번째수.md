## K번째 수
[프로그래머스 K번째 수](https://school.programmers.co.kr/tryouts/71870/challenges)  

## 풀이
~~~java
import java.util.*;

class Solution {
    public int[] solution(int[] array, int[][] commands) {
        int[] answer = new int[commands.length];
        
        int a = 0;
        for(int[] command: commands){
            int i = command[0];
            int j = command[1];
            int k = command[2];
            
            int[] tmp = Arrays.copyOfRange(array,i-1,j);
            Arrays.sort(tmp);
            answer[a++] = tmp[k-1];
        }
        return answer;
    }
}
~~~

~~~java  
import java.util.*;

class Solution {
    public int[] solution(int[] array, int[][] commands) {
        int[] answer = new int[commands.length];
        
        for(int i=0;i<commands.length;i++){
            ArrayList<Integer> tmpArray = new ArrayList<>();
            for(int j=commands[i][0]-1; j<commands[i][1]; j++){
                tmpArray.add(array[j]);
            }
            tmpArray.sort(Comparator.naturalOrder());
            answer[i] = tmpArray.get(commands[i][2]-1);
        }

        return answer;
    }
}
~~~

## 배열을 활용한 풀이
### Arrays.copyOfRange(원본배열, 복사시작인덱스, 복사끝인덱스)
배열 복사  
인덱스는 0부터 시작  
값에의한 복사로 원본배열이 바뀌지않음  

### Arrays.sort()
배열 정렬  
java.util.Arrays 유틸리티클래스를 이용하여 정렬  
기본정렬조건은 오름차순(Class내 기본구현되어있는 인터페이스 Comparable의 compareTo를 기준으로 하기때문)  
#### 내림차순 정렬  
내림차순 정렬 시 Collections.reverseOrder() 를 사용할 수 있는데, WrapperClass를 사용해야한다.(int같은 Primitive Type배열에는 사용불가)  
`Arrays.sort(arr,Collections.reverseOrder())`  
#### 부분 정렬  
일부분만 정렬도 가능하다.  
`Arrays.sort(arr,정렬시작인덱스,정렬끝인덱스)`  

## ArrayList를 활용한 풀이
### ArrayList정렬 - Collections.sort()
- `Collections.sort(list)` : 오름차순으로 정렬  
- `Collections.sort(list, Collections.reverseOrder())` : 내림차순 정렬

### ArrayList정렬 - List.sort()
List객체의 sort()메서드를 사용한 정렬방식  
- `list.sort(Comparator.naturalOrder())` : 오름차순정렬  
- `list.sort(Comparator.reverseOrder())` : 내림차순 정렬  
