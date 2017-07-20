public class OrderDealsExtension {
	
	public List<contentdocumentLink> deals {get;set;}
	public String SelectedDealId {get;set;}
	
	public OrderDealsExtension() {
		loadData();
	}
		
	public void loadData() {
			
		deals = [SELECT ContentDocument.Title,Id,LinkedEntityId,SystemModstamp  FROM ContentDocumentLink where LinkedEntityId ='500i000000FIrlQ'];
	}
	
	public void deleteDeal(){
		if(SelectedDealId == null){
			return;
		}
		//find the deal record within the collection
		contentdocumentLink tobeDeleted = null;
      	for(contentdocumentLink d :deals){
			if(d.Id == SelectedDealId){
				tobeDeleted = d;
                }
			system.debug('**'+tobeDeleted);
			//if deal record found delete it
        }
        if(tobeDeleted != null){
                Delete tobeDeleted;
			}
			
			//refresh the data
			loadData();
		}
}