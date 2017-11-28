using System;
using System.Collections.Generic;
using System.Web.Services;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public partial class BookAdd : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    [WebMethod]
    public static string InventoryAdjust(string NewInv, string OldInv, string rid, string classId)
    {
        string resp = "";
        try
        {
            // get the number of records that need to be added
            int RecordsToAdd = Int32.Parse(NewInv) - Int32.Parse(OldInv);
            for (int i = 0; i < RecordsToAdd; i++)
            {
                string instInvQ = "INSERT INTO Inventory (Book_rid, Classroom_rid, InventoryStatus) VALUES (" + rid +"," + classId + ", 'IN')";
                DBUtility.ExecuteSql(instInvQ, "Library");
            }

            // now fetch back the new inventory count
            string fetchInvQ = "SELECT InventoryCount FROM SelectViewClassroomBook WHERE rid = " + rid + " AND Classroom_rid = " + classId;
            resp = DBUtility.ExecuteScalar(fetchInvQ, "Library");
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string SearchISBN(string val, string classId)
    {
        string resp = "";
        try
        {
            // first check to make sure that we dont already have the book
            string checkQ = "";
            string checkWhere = "";
            switch (val.Length)
            {
                case 10:
                    checkWhere = "WHERE ISBN_10 = '" + val + "'";
                    break;
                case 13:
                    checkWhere = "WHERE ISBN_13 = '" + val + "'";
                    break;
                default:
                    break;
            }
            string bId = "";  // our Id value for the book
            checkQ = "SELECT COUNT(*) FROM SelectViewBook " + checkWhere;
            int checkRet = Int32.Parse(DBUtility.ExecuteScalar(checkQ, "Library"));
            if (checkRet > 0)
            {
                // we have the book. so query for the id
                string getBookIdQ = "SELECT rid FROM SelectViewBook " + checkWhere;
                bId = DBUtility.ExecuteScalar(getBookIdQ, "Library");
            }
            else
            {
                // book is new. create it
                // try first with ISBNDB api. if not found
                // try with OpenLibrary api.
                bId = CreateBookISBNDB(val);
                if (bId == "X")
                {
                    bId = CreateBookOL(val);
                }
            }
            if (bId != "X")
            {
                resp = DisplayBook(bId, classId);
            }
            else
            {
                resp = "X";
                //resp = bId;
            }
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    private static string CreateBookISBNDB(string val)
    {
        string resp = "";
        try
        {
            ISBNCall call = new ISBNCall();
            string callResponse = call.MakeRequest("book", val);
            JObject book = JObject.Parse(callResponse);
            
            if (book["error"] != null)
            {
                // there was an error
                resp = "X";
            }          
            else
            {
                // insert new book record and get rid back
                string isbn10 = (string)book["data"][0]["isbn10"];
                string isbn13 = (string)book["data"][0]["isbn13"];
                string isbnDbId = (string)book["data"][0]["book_id"];
                // due to issue with db trigger, add the book then query for id
                //string instQ = "INSERT INTO Book (ISBN_10,ISBN_13,ISBNDBID) OUTPUT INSERTED.rid VALUES ('" + isbn10 + "','" + isbn13 + "','" + isbnDbId + "')";
                //string bookRid = DBUtility.ExecuteScalar(instQ, "Library");
                string instQ = "INSERT INTO Book (ISBN_10,ISBN_13,ISBNDBID,ISBNDB_SOURCE) VALUES ('" + isbn10 + "','" + isbn13 + "','" + isbnDbId + "','ISBNdbAPI')";
                string instResp = DBUtility.ExecuteSql(instQ, "Library");

                // get rid back
                string getBookIdWhere = "";
                switch (val.Length)
                {
                    case 10:
                        getBookIdWhere = "WHERE ISBN_10 = '" + val + "'";
                        break;
                    case 13:
                        getBookIdWhere = "WHERE ISBN_13 = '" + val + "'";
                        break;
                    default:
                        break;
                }
                string getBookIdQ = "SELECT rid FROM SelectViewBook " + getBookIdWhere;
                string bookRid = DBUtility.ExecuteScalar(getBookIdQ, "Library");

                // now update the book specific values
                string bookTitle = (string)book["data"][0]["title"];
                string bookSummary = (string)book["data"][0]["summary"];
                string bookPubTxt = (string)book["data"][0]["publisher_text"];
                string bUpdtQ = "UPDATE Book SET ";
                bUpdtQ += "BookTitle = dbo.ProperCase('" + bookTitle.Replace("'", "''") + "'), ";
                bUpdtQ += "BookDescription = '" + bookSummary.Replace("'", "''") + "', ";
                bUpdtQ += "PublisherText = '" + bookPubTxt.Replace("'", "''") + "' ";
                bUpdtQ += "WHERE rid = " + bookRid;
                DBUtility.ExecuteSql(bUpdtQ, "Library");

                // now check publisher
                string isbnDbPubId = (string)book["data"][0]["publisher_id"];
                string checkPubQ = "SELECT COUNT(*) FROM Publisher WHERE ISBNDBID = '" + isbnDbPubId + "'";
                int checkPub = Int32.Parse(DBUtility.ExecuteScalar(checkPubQ, "Library"));
                if (checkPub > 0)
                {
                    // we have the publisher, assign to book
                    string getPubRid = "SELECT TOP 1 rid FROM Publisher WHERE ISBNDBID = '" + isbnDbPubId + "'";
                    string oldPubRid = DBUtility.ExecuteScalar(getPubRid, "Library");
                    bUpdtQ = "UPDATE Book SET Publisher_rid = " + oldPubRid + " WHERE rid = " + bookRid;
                    DBUtility.ExecuteSql(bUpdtQ, "Library");
                }
                else
                {
                    // get the publisher from call
                    string pubResponse = call.MakeRequest("publisher", isbnDbPubId);
                    JObject pub = JObject.Parse(pubResponse);
                    string pubName = (string)pub["data"][0]["name"];
                    string pubLocation = (string)pub["data"][0]["location"];
                    string instPubQ = "INSERT INTO Publisher (PublisherName,LocationCity,ISBNDBID) OUTPUT INSERTED.rid VALUES ('" + pubName.Replace("'", "''") + "','" + pubLocation.Replace("'", "''") + "','" + isbnDbPubId + "')";
                    string newPubRid = DBUtility.ExecuteScalar(instPubQ, "Library");
                    bUpdtQ = "UPDATE Book SET Publisher_rid = " + newPubRid + " WHERE rid = " + bookRid;
                    DBUtility.ExecuteSql(bUpdtQ, "Library");
                }

                // now get authors
                JArray authors = (JArray)book["data"][0]["author_data"];
                for (int i = 0; i < authors.Count; i++)
                {
                    string isbnDbAuthId = authors[i]["id"].ToString();
                    // check if we have author
                    string checkAuthorQ = "SELECT COUNT(*) FROM Author WHERE ISBNDBID = '" + isbnDbAuthId + "'";
                    int checkAuthor = Int32.Parse(DBUtility.ExecuteScalar(checkAuthorQ, "Library"));
                    if (checkAuthor > 0)
                    {
                        // get our rid
                        string getAuthorRid = "SELECT rid FROM Author WHERE ISBNDBID = '" + isbnDbAuthId + "'";
                        string oldAuthorRid = DBUtility.ExecuteScalar(getAuthorRid, "Library");
                        // we have author. assign to book
                        string bookAuthQ = "INSERT INTO Book_Author (Book_rid, Author_rid) VALUES (" + bookRid + "," + oldAuthorRid + ")";
                        DBUtility.ExecuteSql(bookAuthQ, "Library");
                    }
                    else
                    {
                        // we need to create the author
                        string authorResponse = call.MakeRequest("author", isbnDbAuthId);
                        JObject auth = JObject.Parse(authorResponse);
                        string authFName = (string)auth["data"][0]["first_name"];
                        string authLName = (string)auth["data"][0]["last_name"];
                        string instAuthQ = "INSERT INTO AUTHOR (FirstName,LastName,ISBNDBID) OUTPUT INSERTED.rid VALUES ('" + authFName.Replace("'", "''") + "','" + authLName.Replace("'", "''") + "','" + isbnDbAuthId + "')";
                        string newAuthorRid = DBUtility.ExecuteScalar(instAuthQ, "Library");

                        string bookAuthQ = "INSERT INTO Book_Author (Book_rid, Author_rid) VALUES (" + bookRid + "," + newAuthorRid + ")";
                        DBUtility.ExecuteSql(bookAuthQ, "Library");
                    }
                }
                resp = bookRid;
            }
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    private static string CreateBookOL(string isbn)
    {
        string resp = "";
        try
        {
            string isbn13 = "";
            string isbn13Inst = "";
            if (isbn.Length == 13)
            {
                // the OpenLibrary service doesnt return 13 digit isbn for some reason..
                // so if our request is 13, we'll send that in 
                isbn13 = isbn;
                isbn13Inst = "'" + isbn13 + "'";
            }
            else
            {
                isbn13Inst = "NULL";
            }
            OLCall call = new OLCall();
            string callResponse = call.MakeRequest("book", isbn);
            if (callResponse == "{}")
            {
                // not found. send back X
                resp = "X";
            }
            else
            {
                JObject book = JObject.Parse(callResponse);
                string isbnKey = "ISBN:" + isbn;

                JObject identifiers = (JObject)book[isbnKey]["identifiers"];
                JArray isbn10Arr = (JArray)identifiers["isbn_10"];
                string isbn10 = (string)isbn10Arr[0];

                JArray olIdArr = (JArray)identifiers["openlibrary"];
                string olId = (string)olIdArr[0];

                // insert the book and get the rid back
                string instQ = "INSERT INTO Book (ISBN_10,ISBN_13,ISBNDBID,ISBNDB_SOURCE) VALUES ('" + isbn10 + "'," + isbn13Inst + ",'" + olId + "','OpenLibraryAPI')";
                DBUtility.ExecuteSql(instQ, "Library");

                // get rid back
                string getBookIdWhere = "";
                switch (isbn.Length)
                {
                    case 10:
                        getBookIdWhere = "WHERE ISBN_10 = '" + isbn + "'";
                        break;
                    case 13:
                        getBookIdWhere = "WHERE ISBN_13 = '" + isbn + "'";
                        break;
                    default:
                        break;
                }
                string getBookIdQ = "SELECT rid FROM SelectViewBook " + getBookIdWhere;
                string bookRid = DBUtility.ExecuteScalar(getBookIdQ, "Library");

                // now update the book with specific values
                string bookTitle = (string)book[isbnKey]["title"];
                JArray pubArr = (JArray)book[isbnKey]["publishers"];
                string bookPubTxt = (string)pubArr[0]["name"];

                string bUpdtQ = "UPDATE Book SET ";
                bUpdtQ += "BookTitle = dbo.ProperCase('" + bookTitle.Replace("'", "''") + "'), ";
                bUpdtQ += "PublisherText = '" + bookPubTxt.Replace("'", "''") + "' ";
                bUpdtQ += "WHERE rid = " + bookRid;
                DBUtility.ExecuteSql(bUpdtQ, "Library");

                // now check publisher
                string checkPubQ = "SELECT COUNT(*) FROM Publisher WHERE PublisherName = '" + bookPubTxt.Replace("'", "''") + "'";
                int checkPub = Int32.Parse(DBUtility.ExecuteScalar(checkPubQ, "Library"));
                if (checkPub > 0)
                {
                    // we have the publisher, assign to book
                    string getPubRid = "SELECT TOP 1 rid FROM Publisher WHERE PublisherName = '" + bookPubTxt.Replace("'", "''") + "'";
                    string oldPubRid = DBUtility.ExecuteScalar(getPubRid, "Library");
                    bUpdtQ = "UPDATE Book SET Publisher_rid = " + oldPubRid + " WHERE rid = " + bookRid;
                    DBUtility.ExecuteSql(bUpdtQ, "Library");
                }
                else
                {
                    // create publisher and assign to book
                    string instPubQ = "INSERT INTO Publisher (PublisherName) OUTPUT INSERTED.rid VALUES ('" + bookPubTxt.Replace("'", "''") + "')";
                    string newPubRid = DBUtility.ExecuteScalar(instPubQ, "Library");
                    bUpdtQ = "UPDATE Book SET Publisher_rid = " + newPubRid + " WHERE rid = " + bookRid;
                    DBUtility.ExecuteSql(bUpdtQ, "Library");
                }

                // do authors
                JArray authors = (JArray)book[isbnKey]["authors"];
                for (int i = 0; i < authors.Count; i++)
                {
                    string authName = (string)authors[i]["name"];
                    string authNameKey = authName.Replace(" ", "");

                    // check author to see if we have this one
                    string checkAuthQ = "SELECT COUNT(*) FROM Author WHERE REPLACE(ISNULL(FirstName,'') + ISNULL(MiddleName,'') + ISNULL(LastName,''),' ','') = '" + authNameKey + "'";
                    int checkAuth = Int32.Parse(DBUtility.ExecuteScalar(checkAuthQ, "Library"));
                    if (checkAuth > 0)
                    {
                        // we have the author so get their id
                        string getAuthRid = "SELECT TOP 1 rid FROM Author WHERE REPLACE(ISNULL(FirstName, '') + ISNULL(MiddleName, '') + ISNULL(LastName, ''), ' ', '') = '" + authNameKey + "'";
                        string oldAuthRid = DBUtility.ExecuteScalar(getAuthRid, "Library");

                        // add the author to the book
                        string bookAuthQ = "INSERT INTO Book_Author (Book_rid, Author_rid) VALUES (" + bookRid + "," + oldAuthRid + ")";
                        DBUtility.ExecuteSql(bookAuthQ, "Library");
                    }
                    else
                    {
                        // we need to create the author
                        // get name
                        string authFName = "";
                        string authLName = "";
                        string[] authNames;
                        authNames = authName.Split(' ');
                        int authNameCt = authNames.Length;
                        authLName = authNames[authNameCt - 1];
                        for (int j = 0; j < authNameCt - 1; j++)
                        {
                            authFName += authNames[j];
                        }

                        string instAuthQ = "INSERT INTO Author (FirstName,LastName) OUTPUT INSERTED.rid VALUES ('" + authFName + "','" + authLName + "')";
                        string newAuthorRid = DBUtility.ExecuteScalar(instAuthQ, "Library");
                        string bookAuthQ = "INSERT INTO Book_Author (Book_rid, Author_rid) VALUES (" + bookRid + "," + newAuthorRid + ")";
                        DBUtility.ExecuteSql(bookAuthQ, "Library");
                    }
                }
                resp = bookRid;
            }
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    private static string DisplayBook(string rid, string classRid)
    {
        string resp = "";
        try
        {
            string selectBookQ = "SELECT * FROM SelectViewClassroomBook WHERE rid = " + rid + " AND Classroom_rid = " + classRid;
            Dictionary<int, Dictionary<string, string>> ret = new Dictionary<int, Dictionary<string, string>>();
            ret = DBUtility.SqlRead(selectBookQ, "Library");
            resp = JsonConvert.SerializeObject(ret[0]);
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }
}