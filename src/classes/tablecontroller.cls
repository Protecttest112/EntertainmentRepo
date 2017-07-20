public class tablecontroller {
    public wrappertable wrapperinstance {get;set;} 
    public List<wrappertable> userInput {get; set;}
    public string phone{get;set;}
    //initiates the controller and displays some initial data when the page loads
    public tablecontroller() {
        userInput = new List<wrappertable>();
        for (integer i =0; i <5;i++){
            wrapperinstance = new wrappertable();
            wrapperinstance.productno='';
            wrapperinstance.lotno='';
            userInput.add(wrapperinstance);
        }
    }
    public class wrappertable{
        
        public string productno{get;set;}
        public string lotno{get;set;}
        public string qty{get;set;}
        public string unitprice{get;set;}
        public string extprice{get;set;}
        
    }
}