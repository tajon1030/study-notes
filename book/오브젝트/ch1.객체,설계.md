## ch1. 객체, 설계

### 정리
- **캡슐화(encapsulation)** : 개념적이나 물리적으로 객체 내부의 세부적인 사항을 감추는 것  
캡슐화의 목적은 변경하기 쉬운 객체를 만드는것  
핵심은 객체 내부의 상태를 캡슐화하고 객체간에 오직 **메시지를 통해서만 상호작용**하도록 만드는 것  
- 밀접하게 연관된 작업만을 수행하고, 연관성 없는 작업은 다른 객체에게 위임하는 객체를 가리켜 **응집도**(cohesion)가 높다고 함  
응집도를 높이기위해서는 객체 **스스로 자신의 데이터를 책임**져야한다.  
- **객체지향 프로그래밍** : **데이터와 프로세스가 동일한 모듈 내부에 위치**하도록 프로그래밍하는 방식  
객체지향 설계에서는 독재자(예제에서의 Theater)가 존재하지않고 각 객체에 책임이 적절하게 분배되어 자신을 스스로 책임진다.  
- 비록 현실에서는 수동적인 존재(예제에서의 Theater, Bag, TicketOffice)라고 하더라도 일단 **객체지향의 세계로 들어오면 모든것이 능동적이고 자율적인 존재**로 바뀐다. (의인화)  
- 객체지향프로그래밍은 의존성을 효율적으로 통제할수있는 다양한 방법을 제공함으로써 요구사항변경에 좀 더 수월하게 대응할 수 있는 가능성을 높여준다.  
- 훌륭한 객체지향 설계란 협력하는 객체사이의 의존성을 적절하게 관리하는 설계다.  
(예제 TicketSeller.sellTo에서 적절한 트레이드오프를 통해 의존성을 관리하였음)  


### 예제 - 티켓판매애플리케이션  
#### 요구사항
- 극장은 직원이 관리함  
- 직원은 매표소에서 티켓판매역할을 수행함  
- 극장에 들어가기 위해서는 무료관람초대장이 있거나 돈을주고 티켓을 구매해야함  
- 직원은 관람객을 입장시키기전에 이 초대장소유여부를 확인해야하고 소유자가 아닌경우 티켓을 판매한후 입장시켜야함  
- 관객은 가방을 들고있고 가방안에는 돈, 초대장, 티켓이 있음  


#### 구현1
~~~java
@AllArgsConstructor
public class Theater {
    private TicketSeller ticket Seller; // 극장의 직원

    /**
    * 관객을 입장시키기위한 메서드
    **/
    public void enter(Audience audience){ 
        if(audience.getBag().hasInvitation()){ // 관객의 가방을 열어 초대장이 있는지 살펴봄
            // 직원이 일하는 매표소에서 티켓을 찾음
            Ticket ticket = ticketSeller.getTicketOffice().getTicket();
            // 관객의 가방에 직접 티켓을 넣어줌
            audience.getBag().setTicket(ticket);
        } else {
            // 직원이 일하는 매표소에서 티켓을 찾아옴
            Ticket ticet = ticeketSeller.getTicketOffice().getTicket();
            // 관객의 가방에서 티켓금액을 뺌
            audience.getBag().minusAmount(ticket.getFee());
            // 직원이 일하는 매표소의 현금을 티켓가격만큼 더해줌
            ticketSeller.getTicketOffice().plusAmount(ticket.getFee());
            // 관객의 가방에 직접 티켓을 넣어줌
            audience.getBag().setTicket(ticket);
        }
    }
}
~~~

문제점 : 관람객과 판매원이 소극장의 통제를 받고 있다.  
-> 1. 예상을 벗어나는 코드(극장이 모든것을 통제한다? && 매표소에서 어디까지 알고있어야하는것?) -> 가독성이 떨어짐(이해하기어려움)  
-> 2. Audience와 TicketSeller를 변경할 경우 Theater도 변경해야함 -> 의존성이 너무 강함 -> 변경에 취약  


### 구현2 (개선본)
인스턴스변수를 private으로 만들고 getter를 없애서 캡슐화  
~~~java
/**
 * 극장
 **/
@AllArgsConstructor
public class Theater {
    private TicketSeller ticket Seller;

    public void enter(Audience audience){ 
        // Theater는 seller의 interface에만 의존함
        // ticketOffice가 seller내부에 존재한다는 사실을 모름
        ticketSeller.sellTo(audience);
    }
}

/**
 * 직원
 **/
@AllArgsConstructor
public class TicketSeller {
    private TicketOffice ticketOffice;

    public void sellTo(Audience audience){
        // seller가 ticketOffice의 자율성을 침해하고있지만
        // 자율성을 만족시키는 구현시 TicketOffice가 다시 Audience에 대한 의존성이 추가되어 트레이드오프
        ticketOffice.plusAmount(audience.buy(ticketOffice.getTicket()));
    }
}

/**
 * 관람객
 **/
@AllArgsConstructor
public class Audience {
    private Bag bag;

    public Long buy(Ticket ticket){
        // 가방이 능동적으로 hold? -> 객체지향의 특징
        return bag.hold(ticket);
    }
}

/**
 * 가방
 **/
public class Bag {
    private Long amount;
    private Ticket ticket;
    private Invitation invitation; // 초대장

    public Long hold(Ticket ticket) {
        if(hasInvitation()){
            setTicket(ticket);
            return 0L;
        }else {
            setTicket(ticket);
            minusAmount(ticket.getFee());
            return ticket.getFee();
        }
    }

    private void setTicket(Ticket ticket){
        this.ticket = ticket;
    }

    private boolean hasInvitation() {
        return invitation != null;
    }
}

/**
 * 매표소
 **/
public class TicketOffice {
    private Long amount;
    private List<Ticket> tickets = new ArrayList<>();

    public TicketOffice(Long amount, TicketOffice ticketOffice){
        this.amount = amount;
        this.tickets.addAll(Arrays.asList(tickets));
    }

    private Ticket getTicket(){
        // 티켓판매시 가장 위에있는 티켓을 제거
        return tickets.remove(0);
    }

    private void plusAmount(Long amount) {
        this.amount += amount;
    }
}
~~~