public class pageblockwidth {

    public List<contact> getContacts() {
        return [select Id, name from contact];
    }

}