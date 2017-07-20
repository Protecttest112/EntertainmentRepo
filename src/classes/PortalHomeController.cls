public class PortalHomeController{
    
    public String jsonString{
    get{
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('Id', '003i000004SddG5AAJ');
        gen.writeEndObject();
        return gen.getAsString();
    }
    set;}
    public PortalHomeController(){
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');  
    }
   }