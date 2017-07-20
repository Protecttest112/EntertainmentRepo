public class batchtestcontroller{
    public date userDate { get; set; }
    public String username {get; set;}
    public date d1;
    
    public batchtestcontroller() {
    username=UserInfo.getUserName();
    system.debug('constructor---'+username);
    }

    public void sendEmail(){     
    system.debug('batchcall');
    d1=userDate;
    system.debug('date11'+d1);
   // batchEmailRecruiters batch = new batchEmailRecruiters (d1);
  //  Database.executeBatch(batch);
    }
}