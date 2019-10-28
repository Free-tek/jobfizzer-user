import Foundation
import UIKit

struct APIList
{
    
    //http://139.59.6.161/uberdoo
    //    let ADMIN_BASE_URL = "http://104.131.74.144/uber_test/public/admin/"
    //    let BASE_URL = "http://104.131.74.144/uber_test/public/api/"
    let ADMIN_BASE_URL = "http://18.223.84.90/uberdoo/public/admin/"
    let BASE_URL = "http://18.223.84.90/uberdoo/public/api/"
    let SOCKET_MESSAGE = "http://18.223.84.90:3000/"
    let SOCKET_URL = "http://18.223.84.90:3000/"
    let SOCKET_URL_PRO = "http://18.223.84.90:3000/"
    
    func getUrlString(url: urlString) -> String
    {
        return BASE_URL + url.rawValue
    }
    func getAdminUrlString(url: urlString) -> String
    {
        return ADMIN_BASE_URL + url.rawValue
    }
    func getSocketUrlString(url: urlString) -> String
    {
        return SOCKET_MESSAGE + url.rawValue
    }
}

enum urlString: String
{
    case ADDADDRESS = "addaddress"
    case LOGOUT = "logout"
    case APPSETTINGS = "appsettings"
    case LISTADDRESS = "listaddress"
    case DELETEADDRESS = "deleteaddress"
    case CANCELBYUSER = "cancelbyuser"
    case VIEWBOOKINGS = "view_bookings"
    case CHANGEPASSWORD = "changepassword"
    case NEWBOOKING = "newbooking"
    case FORGOTPASSWORD = "forgotpassword"
    case HOMEDASHBOARD = "homedashboard"
    case HOMEDASHBOARDNEW = "homedashboardnew"
    case PAY = "pay"
    case COUPONVERIFY = "couponverify"
    case COUPONREMOVE = "couponremove"
    case UPDATEADDRESS = "updateaddress"
    case FORGOTOTPCHECK = "forgotpasswordotpcheck"
    case RESETPASSWORD = "resetpassword"
    case REVIEW = "review"
    case CANCELREQUEST = "cancel_request"
    case LISTPROVIDER = "listprovider"
    case SOCIALLOGIN = "sociallogin"
    case USERLOGIN = "userlogin"
    case UPDATEDEVICETOKEN = "updatedevicetoken"
    case SIGNUP = "signup"
    case LISTSUBCATEGORY = "list_subcategory"
    case GETPROVIDERLOCATION = "getproviderlocation"
    case VIEWPROFILE = "viewprofile"
    case UPDATEPROFILE = "updateprofile"
    case SHOWPAG = "showPag"
    case IMAGEUPLOAD = "imageupload"
    case PROVIDERMSGLIST = "providermsglist"
    case USERCHATLIST = "userchatlist"
    case PAYSTACKACCESS = "paystack_access"
    case PAYSTACKPAYMENTSTATUS = "paystack_payment_status"
    
}

