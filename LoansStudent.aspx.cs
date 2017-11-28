using System;
using System.Collections.Generic;
using System.Web.Services;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public partial class LoansStudent : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    [WebMethod]
    public static string GetYearStudents(string rid, string classId)
    {
        string resp = "";

        try
        {
            string yearQ = "SELECT * FROM SelectViewStudent WHERE SchoolYear_rid = " + rid + " AND Classroom_rid = " + classId + " ORDER BY StudentName";
            Dictionary<int, Dictionary<string, string>> ret = DBUtility.SqlRead(yearQ, "Library");
            resp = JsonConvert.SerializeObject(ret);
        }
        catch (Exception e)
        {
            resp = "X";
        }

        return resp;
    }

    [WebMethod]
    public static string GetStudentLoans(string rid, string classId)
    {
        string resp = "";
        try
        {
            string stuQ = "SELECT * FROM StudentLoan WHERE Student_rid = " + rid + " ORDER BY CheckOutDateTime DESC";
            Dictionary<int, Dictionary<string, string>> ret = DBUtility.SqlRead(stuQ, "Library");
            resp = JsonConvert.SerializeObject(ret);
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }
}