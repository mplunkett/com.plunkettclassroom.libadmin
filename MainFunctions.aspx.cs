using System;
using System.Collections.Generic;
using System.Web.Services;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public partial class MainFunctions : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    [WebMethod]
    public static string GetClassStats(string classId)
    {
        string resp = "";
        try
        {
            string bookQ = "SELECT COUNT(*) FROM Inventory WHERE InventoryStatus != 'RETIRED' AND Classroom_rid = " + classId;
            string bookCt = DBUtility.ExecuteScalar(bookQ, "Library");

            string stuQ = "SELECT COUNT(*) FROM Student WHERE Active = 1 AND Classroom_rid = " + classId;
            string stuCt = DBUtility.ExecuteScalar(stuQ, "Library");

            string loanQ = "SELECT COUNT(l.rid) FROM Loans l LEFT OUTER JOIN Inventory i ON l.Inventory_rid = i.rid WHERE i.Classroom_rid = " + classId;
            string loanCt = DBUtility.ExecuteScalar(loanQ, "Library");

            Dictionary<string, string> retDict = new Dictionary<string, string>();
            retDict.Add("BookCount", bookCt);
            retDict.Add("StudentCount", stuCt);
            retDict.Add("LoanCount", loanCt);

            resp = JsonConvert.SerializeObject(retDict);
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }
}