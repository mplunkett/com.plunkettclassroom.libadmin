<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeFile="UsersMain.aspx.cs" Inherits="UsersMain" %>
<%@ MasterType VirtualPath="~/Main.master" %>
<asp:Content ID="Content3" ContentPlaceHolderID="pagejs" Runat="Server">
    <script type="text/javascript">
        function GetYear(rid) {
            $("#YearId").val(rid);
            var classId = $("#LoggedClassVal").val();
            $.ajax({
                type: "POST",
                url: "UsersMain.aspx/GetYearStudents",
                data: "{rid: '" + rid + "', classId: '" + classId + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    $("#rsltTbl tbody").html("");
                    var resp = msg.d;
                    var retObj = jQuery.parseJSON(resp);

                    var elements = "";
                    $.each(retObj, function(key, value) {
                        var element = "";
                        element += "<tr>";
                        element += "<td>" + value.StudentName + "</td>";
                        element += "<td>" + value.SchoolYearName + "</td>";
                        element += "<td>" + value.Active + "</td>";
                        element += "<td><button type='button' onclick='ShowEditStudentModal(" + value.rid + ");' class='btn btn-link'><i class='fa fa-pencil'></i></button></td>";
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

        function ShowEditStudentModal(rid) {
            var classId = $("#LoggedClassVal").val();
            $("#EditStuId").val(rid);            
            var dataString = "{classId: '" + classId + "',stuId: '" + rid + "'}";
            $.ajax({
                type: "POST",
                url: "UsersMain.aspx/ShowEditStudentModal",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    if (resp != "X") {
                        var retObj = jQuery.parseJSON(resp);
                        $("#EditStuName").val(retObj.StudentName);
                        if (retObj.Active == "True") {
                            $("#EditStuActive").prop("checked","checked");
                        }
                        $("#EditModal").modal("show");
                    }
                    else {
                        alert("There was an error loading student modal");
                    }
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax failure\nBOOOO \n" + exception);
                },
                async: false
            });
        }

        function EditStudent() {
            var stuId = $("#EditStuId").val();
            var stuName = $("#EditStuName").val();
            var stuActive = "";
            if ($("#EditStuActive").is(":checked")) {
                stuActive = "1";
            }
            else {
                stuActive = "0"
            }
            var year = $("#YearId").val();

            var dataString = "{stuId: '" + stuId + "',stuName: '" + stuName + "',stuActive: '" + stuActive + "'}";
            $.ajax({
                type: "POST",
                url: "UsersMain.aspx/EditStudent",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    if (resp != "X") {
                        GetYear(year);
                        $("#EditModal").modal("hide");
                    }
                    else {
                        alert("There was an error saving changes");
                    }
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax failure\nBOOOO \n" + exception);
                },
                async: false
            });
        }

        function ShowAddUserModal() {
            $("#AddSchYearSel").val("");
            $("#AddStuName").val("");
            $("#AddModal").modal("show");
        }

        function AddStudent() {
            var classId = $("#LoggedClassVal").val();
            var stuYear = $("#AddSchYearSel").val();
            var stuName = $("#AddStuName").val().replace("'","''");

            if (stuYear == "" || stuYear == "") {
                alert("Please fill out all fields.");
                return;
            }

            var dataString = "{classId: '" + classId + "',stuYear: '" + stuYear + "',stuName: '" + stuName + "'}";
            $.ajax({
                type: "POST",
                url: "UsersMain.aspx/AddNewStudent",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {                   
                    var resp = msg.d;
                    if (resp == "X") {
                        alert("There was an error inserting the student");
                    }
                    else {
                        GetYear(stuYear);
                        $("#AddModal").modal("hide");
                    }
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
    <h2 class="pull-left"><i class="fa fa-users"></i> Students</h2>
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
            <div class="widget wgreen">
                <div class="widget-head" id="YearName">
                    <input type="hidden" id="YearId" value="" />
                    <div class="row">
                        <div class="col-lg-3 col-md-3 col-sm-3">
                            <form role="form">
                                <div class="form-group">
                                    <button type="button" class="btn btn-link" id="AddStudentBtn" onclick="ShowAddUserModal();"><i class="fa fa-user"></i> Add Student</button>
                                </div>
                            </form>
                        </div>
                    </div>
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
                                        <th>Status</th>
										<th>Edit</th>
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
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="ModalContent" Runat="Server">
    <div id="EditModal" class="modal fade" role="dialog">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <input type="hidden" id="EditStuId" value="" />
                    Edit Student
                </div>
                <div class="modal-body">
                    <form role="form">
                        <div class="form-group">
                            <label>Student Name</label>
                            <input type="text" class="form-control" id="EditStuName" value="" />
                        </div>
                        <div class="form-group">
                            <label>Active?</label>
                            <input type="checkbox" id="EditStuActive" />
                        </div>
                    </form>
                    <button type="button" class="btn btn-primary" onclick="EditStudent();">Save</button>
                </div>
                <div class="modal-footer">

                </div>
            </div>
        </div>
    </div>
    <div id="AddModal" class="modal fade" role="dialog">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    Add Student
                </div>
                <div class="modal-body">
                    <form role="form">
                        <div class="form-group">
                            <label>Select School Year</label>
                            <select id="AddSchYearSel" class="form-control">
                                <option value="">Select...</option>
                                <%
                                    string sYearQ = "SELECT * FROM SchoolYear ORDER BY StartDate DESC";
                                    Dictionary<int, Dictionary<string, string>> years = DBUtility.SqlRead(sYearQ, "Library");
                                    for (int i = 0; i < years.Count; i++)
                                    {
                                        Dictionary<string, string> year = years[i];
                                        string yearName = year["SchoolYearName"];
                                        string yearRid = year["rid"];
                                        Response.Write("<option value='" + yearRid + "'>" + yearName + "</option>");
                                    }
                                %>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Student Name</label>
                            <input type="text" value="" class="form-control" id="AddStuName" />
                        </div>
                    </form>
                    <button type="button" class="btn btn-primary" onclick="AddStudent();">Add</button>
                </div>
                <div class="modal-footer">

                </div>
            </div>
        </div>
    </div>
</asp:Content>
