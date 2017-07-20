@isTest
public class Test_contactUsController
{
    static  testmethod void TestContactUs()
    {
        ContactUsController ctrl=new ContactUsController();
        ctrl.submitcase();
        ctrl.question='test';
        ctrl.submitcase();
    }
}