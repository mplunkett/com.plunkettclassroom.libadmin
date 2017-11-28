using System;
using System.Net;

/// <summary>
/// Summary description for ISBNCall
/// </summary>
public class OLCall
{
    public string BaseUrl { get; set; }    

    public OLCall()
    {
        this.BaseUrl = "https://openlibrary.org/api/books?bibkeys=ISBN:{0}&format=json&jscmd=data";       
    }

    public string MakeRequest(string obj, string val)
    {
        string resp = "";
        try
        {
            string request = String.Format(BaseUrl, val);
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