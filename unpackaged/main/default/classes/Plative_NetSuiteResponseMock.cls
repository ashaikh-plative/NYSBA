/**
* Company     : Plative
* Description : Mock class for reponse from Netsuite
* [27.May.2020] Anisa - Code Creation 
*/
public class Plative_NetSuiteResponseMock implements HttpCalloutMock {

	public static HttpResponse respond(HttpRequest request){
		
		HttpResponse response = new HttpResponse();
		response.setHeader('Location','/12345');
		response.setStatusCode(204);
		return response;
	}
}