global class StandardUserRegistrationHandler implements Auth.RegistrationHandler{
global User createUser(Id portalId, Auth.UserData data){
    User u = new User();
    Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
    system.debug('%%%'+data);
    system.debug('%%%'+data.username);
    u.username = data.email;
    u.email = data.email;
    u.lastName = data.lastName;
    u.firstName = data.firstName;
    u.alias = 'alias112';
    u.languagelocalekey = 'en_US';
    u.localesidkey = data.locale;
    u.emailEncodingKey = 'UTF-8';
    u.timeZoneSidKey = 'America/Los_Angeles';
    u.profileId = p.Id;
    system.debug('$$$1'+portalId+'%%%1'+u);
    return u;
}

global void updateUser(Id userId, Id portalId, Auth.UserData data){
    User u = new User();
    u.username = data.username + '@salesforce.com';
    u.email = data.email;
    u.lastName = data.lastName;
    u.firstName = data.firstName;
    u.ProfileId='00ei0000001dffr';
    u.emailEncodingKey = 'UTF-8';
    u.timeZoneSidKey = 'America/Los_Angeles';
    String alias = data.email;
    u.alias = 'aliascom';
    u.languagelocalekey = 'en_US';
    u.localesidkey = data.locale;
    u.IsActive=true;
    contact c = new contact();
    c.lastName='john humberg';
    c.AccountId='001i0000026cjRA';
    insert c;
    u.ContactId=c.Id;
    insert (u);
    system.debug('$$$'+userId+'%%%'+portalId+'^^^'+u.Id);
}
}