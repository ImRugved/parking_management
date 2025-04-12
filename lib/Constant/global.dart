class Global {
  //local
  //static const hostUrl = "http://192.168.10.209:8091";//ravima
  //static const hostUrl = "http://103.16.222.181:7072";//mital group
  //static const hostUrl = "http://192.168.10.155:84"; // adity birla
  //static const hostUrl = "http://192.168.10.179:8084"; // adity birla new test
  //dev url
 static const hostUrl = 'http://10.4.0.41:81'; //live
  //LoginApi call
  static const logInApi = "/api/Login/CheckUsercredentials";
  //JswAuthToken
  static const jswTokenApi = "/api/Login/JWTToken";
  //get Vehicle rate for visitor
  static const getVehicleRate = '/api/login/GetVehicalerateForVisitor';
  //inset vehicle Entry
  static const insertVehicleEntry = '/api/Login/InsertvehicleEntry';
  //Scan Qr vehicle Entry
  static const scanQr = '/api/Login/VisitorBillEntry';
  //getOfficeName
  static const getOfficeName = '/api/login/GetOfficeNamelist';
}
//https://localhost:44365/api/login/GetVehicalerateForVisitor?UserID=30044
//https://localhost:44365/api/Login/InsertvehicleEntry
