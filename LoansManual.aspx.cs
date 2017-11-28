using System;
using System.Collections.Generic;
using System.Web.Services;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public partial class LoansManual : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    [WebMethod]
    public static string GetInventoryDetail(string bookId, string classId)
    {
        string resp = "";
        try
        {
            Dictionary<string, string> retObj = new Dictionary<string, string>();
            // first check the books status
            string checkQ = "SELECT * FROM InventoryBookNameView WHERE InventoryRid = " + bookId + " AND Classroom_rid = " + classId;
            Dictionary<int, Dictionary<string, string>> ret = DBUtility.SqlRead(checkQ, "Library");
            if (ret.Count > 0)
            {
                retObj = ret[0];
                string invStatus = retObj["InventoryStatus"];

                if (invStatus == "OUT")
                {
                    // book is checked out. so get the loan details
                    string loanQ = "SELECT TOP 1 * FROM StudentLoan WHERE LoanStatus = 'CHECKEDOUT' AND CheckInDate IS NULL AND Inventory_rid = " + bookId;
                    Dictionary<int, Dictionary<string, string>> loanRet = DBUtility.SqlRead(loanQ, "Library");
                    if (loanRet.Count > 0)
                    {
                        Dictionary<string, string> loanRetObj = loanRet[0];
                        retObj.Add("LoanFound", "1");
                        retObj.Add("LoanId", loanRetObj["LoanId"]);
                        retObj.Add("LoanStudent", loanRetObj["StudentName"]);
                    }
                    else
                    {
                        retObj.Add("LoanFound", "0");
                    }
                }
            }
            else
            {
                retObj.Add("InventoryStatus", "UNKNOWN");
            }
            resp = resp = JsonConvert.SerializeObject(retObj);
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string GetStudents(string classId)
    {
        string resp = "";
        try
        {
            string stuQ = "SELECT * FROM Student WHERE Active = 1 AND Classroom_rid = " + classId + " ORDER BY StudentName";
            Dictionary<int, Dictionary<string, string>> ret = DBUtility.SqlRead(stuQ, "Library");
            resp = JsonConvert.SerializeObject(ret);
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string CheckInBook(string loanId, string bookId)
    {
        string resp = "";
        try
        {
            string checkinQ = "UPDATE Loans SET CheckInDate = GetDate(), LoanStatus = 'RETURNED' WHERE rid = " + loanId;
            DBUtility.ExecuteSql(checkinQ, "Library");

            string invQ = "UPDATE Inventory SET InventoryStatus = 'IN' WHERE rid = " + bookId;
            DBUtility.ExecuteSql(invQ, "Library");

            resp = "OK";
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string CheckOutBook(string stuId, string bookId)
    {
        string resp = "";
        try
        {
            string checkoutQ = "INSERT INTO Loans (LoanStatus,Student_rid,Inventory_rid) VALUES ('CHECKEDOUT'," + stuId + "," + bookId + ")";
            DBUtility.ExecuteSql(checkoutQ, "Library");

            string invQ = "UPDATE Inventory SET InventoryStatus = 'OUT' WHERE rid = " + bookId;
            DBUtility.ExecuteSql(invQ, "Library");

            resp = "OK";
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

}