using System;
using System.Collections.Generic;
using System.Web.Services;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public partial class LoansMain : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    [WebMethod]
    public static string GetInventory(string classId)
    {
        string resp = "";
        try
        {
            string invQ = "SELECT * FROM InventoryClassBookView WHERE Classroom_rid = " + classId + " ORDER BY BookTitle";
            Dictionary<int, Dictionary<string, string>> ret = DBUtility.SqlRead(invQ, "Library");
            resp = JsonConvert.SerializeObject(ret);
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string GetLoans(string classId, string bookId, string yearId, string status)
    {
        string resp = "";
        try
        {
            string loanQ = "SELECT * FROM StudentLoan WHERE Classroom_rid = " + classId;
            if (bookId != "")
            {
                loanQ += " AND Book_rid = " + bookId;
            }
            if (yearId != "")
            {
                loanQ += " AND SchoolYear_rid = " + yearId;
            }
            if (status != "")
            {
                loanQ += " AND LoanStatus = '" + status + "'";
            }
            loanQ += " ORDER BY CheckOutDateTime DESC";
            Dictionary<int, Dictionary<string, string>> ret = DBUtility.SqlRead(loanQ, "Library");
            resp = JsonConvert.SerializeObject(ret);
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }
}