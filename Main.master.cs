using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Main : System.Web.UI.MasterPage
{

    protected void Page_Load(object sender, EventArgs e)
    {
        string User = System.Web.HttpContext.Current.User.Identity.Name;
        int domainStart = User.IndexOf("\\");
        string UserName = User.Substring(domainStart + 1);
        //tst.Text = User;
        tst.Text = UserName;

        string verifyQ = "SELECT * FROM SystemUser WHERE Active = 1 AND UserName = '" + UserName + "'";
        Dictionary<int, Dictionary<string, string>> result = DBUtility.SqlRead(verifyQ, "Library");
        if (result.Count > 0)
        {
            Dictionary<string, string> userResult = result[0];
            LoggedClassVal.Value = userResult["Classroom_rid"];
            LoggedUserVal.Value = userResult["rid"];
        }
        else
        {
            // redirect
            // for dev just set to 1
            //LoggedClassVal.Value = "1";
            //LoggedUserVal.Value = "1";
        }
    }
}
