public class fromJSON{
	public String action;	//create
	public cls_user_info user_info;
	public class cls_user_info {
		public String email ;	//Spartan093@outlook.com
		public Integer type ;	//1
		public String first_name ;	//睿欣
		public String last_name ;	//肖
		public String password ;	//123456787
	}
	public static fromJSON parse(String json){
		return (fromJSON) System.JSON.deserialize(json, fromJSON.class);
	}
/*
	static testMethod void testParse() {
		String json=		'{'+
		'  "action": "create",'+
		'  "user_info": {'+
		'    "email": "Spartan093@outlook.com",'+
		'    "type": 1,'+
		'    "first_name": "睿欣",'+
		'    "last_name": "肖",'+
		'    "password": "123456787"'+
		'  }'+
		'}'+
		'';
		fromJSON obj = parse(json);
		System.assert(obj != null);
	}
*/
}