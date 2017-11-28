<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeFile="LoansStudent.aspx.cs" Inherits="LoansStudent" %>

<asp:Content ID="Content3" ContentPlaceHolderID="pagejs" Runat="Server">
    <script type="text/javascript">
        function GetYear(rid) {
            $("#YearId").val(rid);
            var classId = $("#LoggedClassVal").val();
            $.ajax({
                type: "POST",
                url: "LoansStudent.aspx/GetYearStudents",
                data: "{rid: '" + rid + "', classId: '" + classId + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    $("#rsltTbl tbody").html("");
                    $("#loansTbl tbody").html("");
                    var resp = msg.d;
                    var retObj = jQuery.parseJSON(resp);

                    var elements = "";
                    $.each(retObj, function(key, value) {
                        var element = "";
                        element += "<tr>";
                        element += "<td>" + value.StudentName + "</td>";
                        element += "<td>" + value.SchoolYearName + "</td>";
                        element += "<td><button type='button' onclick='ShowStudentLoans(" + value.rid + ");' class='btn btn-link'><i class='fa fa-search'></i></button></td>";
                        element += "</tr>";
                        elements += element;
                    });
                    $("#rsltTbl tbody").html(elements);
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax failure\nBOOOO \n" + exception);
                },
                async: false
            });
        }

        function ShowStudentLoans(rid) {
            $("#StudentId").val(rid);
            var classId = $("#LoggedClassVal").val();
            $.ajax({
                type: "POST",
                url: "LoansStudent.aspx/GetStudentLoans",
                data: "{rid: '" + rid + "', classId: '" + classId + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    $("#loansTbl tbody").html("");
                    var resp = msg.d;
                    var retObj = jQuery.parseJSON(resp);

                    var elements = "";
                    $.each(retObj, function (key, value) {
                        var element = "";
                        element += "<tr>";
                        element += "<td>" + value.BookTitle + "</td>";
                        element += "<td>" + value.CheckOutDate + "</td>";
                        element += "<td>" + value.LoanStatus + "</td>";
                        element += "<td>" + value.StudentName + "</td>";
                        element += "</tr>";
                        elements += element;
                    });
                    $("#loansTbl tbody").html(elements);
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax failure\nBOOOO \n" + exception);
                },
                async: false
            });
        }

    </script>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="pagetitle" Runat="Server">
    <h2 class="pull-left"><i class="fa fa-bar-chart-o"></i> Loans by Student</h2>
    <div class="clearfix"></div>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <div class="row">
        <div class="col-lg-3 col-md-3">
            <div class="widget wgreen">
                <div class="widget-head">
                    School Year
                </div>
                <div class="widget-content">
                    <div class="padd">
                        <!-- Form Here -->
                        <form role="form">
                            <%
                                string sYearQ = "SELECT * FROM SchoolYear ORDER BY StartDate DESC";
                                Dictionary<int, Dictionary<string, string>> years = DBUtility.SqlRead(sYearQ, "Library");
                                for (int i = 0; i < years.Count; i++)
                                {
                                    Dictionary<string, string> year = years[i];
                                    string yearName = year["SchoolYearName"];
                                    string yearRid = year["rid"];
                                    Response.Write("<div class='form-group'><button type='button' onclick='GetYear(" + yearRid + ");' class='btn btn-default form-control'>" + yearName + "</button></div>");
                                }
                            %>
                        </form>
                    </div>
                </div>
                <div class="widget-foot">

                </div>
            </div>
        </div>
        <div class="col-lg-9 col-md-9">
            <div class="row">
                <div class="col-lg-12">
                    <div class="widget wgreen">
                        <div class="widget-head">
                            <input type="hidden" id="YearId" value="" />
                            Select Student
                        </div>
                        <div class="widget-content">
                            <div class="padd">
                                <!-- Form Here -->
                                <div id="rslts">
                                    <table class="table table-hover" id="rsltTbl">
							            <thead>
								            <tr>
									            <th>Student</th>
										        <th>Year</th>
										        <th>View</th>
									        </tr>
								        </thead>
								        <tbody>
									
								        </tbody>
							        </table>
                                </div>
                            </div>
                        </div>
                        <div class="widget-foot">

                        </div>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <div class="widget wgreen">
                        <div class="widget-head">
                            <input type="hidden" id="StudentId" value="" />
                            Loan History
                        </div>
                        <div class="widget-content">
                            <div class="padd">
                                <!-- Form Here -->
                                <div id="loans">
                                    <table class="table table-hover" id="loansTbl">
							            <thead>
								            <tr>
									            <th>Book</th>
										        <th>Checkout Date</th>
                                                <th>Status</th>
                                                <th>Student</th>
									        </tr>
								        </thead>
								        <tbody>
									
								        </tbody>
							        </table>
                                </div>
                            </div>
                        </div>
                        <div class="widget-foot">

                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="ModalContent" Runat="Server">

</asp:Content>

