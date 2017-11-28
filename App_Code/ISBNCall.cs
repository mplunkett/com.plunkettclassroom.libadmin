using System;
using System.Net;

/// <summary>
/// Summary description for ISBNCall
/// </summary>
public class ISBNCall
{
    public string BaseUrl { get; set; }
    public string ApiKey { get; set; }

    public ISBNCall()
    {
        this.BaseUrl = "http://isbndb.com/api/v2/json/";
        this.ApiKey = "EEYQJFI1";
    }

    public string MakeRequest(string obj, string val)
    {
        string resp = "";

        try
        {
            string request = BaseUrl + ApiKey + "/" + obj + "/" + val;
            //string request = "http://isbndb.com/api/v2/json/EEYQJFI1/book/084930315X";
            using (WebClient client = new WebClient())
            {
                resp = client.DownloadString(request);                
            }
        }
        catch (Exception e)
        {
            resp = "X";
        }

        return resp;
    }
}