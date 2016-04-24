@isTest()
public class MyPayeGetPayruns_test{

    static testMethod void MyPayeGetPayruns_Test1(){
    
    Account a = new Account(name='test');
    insert a;
    
    
    
     // TESTA PÁGINA:
        Test.setCurrentPageReference(new PageReference('Page.MyPayeGetPayruns')); 
        System.currentPageReference().getParameters().put('id', a.id);
        MyPayeGetPayruns contr = new MyPayeGetPayruns();
    
    }


}