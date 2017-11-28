<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeFile="BookAddManual.aspx.cs" Inherits="BookAdd" %>
<asp:Content ID="Content3" ContentPlaceHolderID="pagejs" Runat="Server">
    <script type="text/javascript">
        $(document).ready(function () {
            GetAuthorList();
            GetPublisherList();
        });

        function GetAuthorList() {
            $("#AuthorSel").html("");
            var dataString = "{}";
            $.ajax({
                type: "POST",
                url: "BookAddManual.aspx/GetAuthors",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    $("#AuthorSel").append("<option value=''>Select...</option>");
                    var resp = msg.d;
                    var retObj = jQuery.parseJSON(resp);
                    $.each(retObj, function (key, value) {
                        var newOp = "<option value='" + value.rid + "'>" + value.FirstName + " " + value.LastName + "</option>";
                        $("#AuthorSel").append(newOp);
                    });
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax error: " + exception);
                },
                async: false
            });
        }

        function GetPublisherList() {
            $("#PublisherSel").html("");
            var dataString = "{}";
            $.ajax({
                type: "POST",
                url: "BookAddManual.aspx/GetPublishers",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    $("#PublisherSel").append("<option value=''>Select...</option>");
                    var resp = msg.d;
                    var retObj = jQuery.parseJSON(resp);
                    $.each(retObj, function (key, value) {
                        var newOp = "<option value='" + value.rid + "'>" + value.PublisherName + "</option>";
                        $("#PublisherSel").append(newOp);
                    });
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax error: " + exception);
                },
                async: false
            });
        }

        function AddNewBook() {
            var classId = $("#LoggedClassVal").val();
            var title = $("#BookTitle").val().replace(/'/gi,"`");
            var isbn10 = $("#ISBN10").val().replace(/'/gi, "`");
            var isbn13 = $("#ISBN13").val().replace(/'/gi, "`");
            var inv = $("#Inventory").val().replace(/'/gi, "`");
            var authSel = $("#AuthorSel").val();
            var authEnter = $("#AuthorEnter").val().replace(/'/gi, "`");
            var pubSel = $("#PublisherSel").val();
            var pubEnter = $("#PublisherEnter").val().replace(/'/gi, "`");

            var dataString = "{title: '" + title + "',isbn10: '" + isbn10 + "',isbn13: '" + isbn13 + "',inv: '" + inv + "',authSel: '" + authSel + "',authEnter: '" + authEnter + "',pubSel: '" + pubSel + "',pubEnter: '" + pubEnter + "',classId: '" + classId + "'}";
            $.ajax({
                type: "POST",
                url: "BookAddManual.aspx/AddNewBook",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    alert(resp);
                    location.reload();
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax error: " + exception);
                },
                async: false
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="pagetitle" Runat="Server">
    <h2 class="pull-left"><i class="fa fa-book"></i> Add Books Manual</h2>
    <div class="clearfix"></div>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<div class="row">
	    <div class="col-lg-6 col-md-6">
	        <div class="widget wgreen">
			    <div class="widget-head">
                    Book Details
				</div>
				<div class="widget-content">
				    <div class="padd">
					<!--Form here-->
					    <div id="results">
                            <form class="form-horizontal" role="form">
                                <div class="form-group">
                                    <label class="col-lg-2 control-label">Title</label>
                                    <div class="col-lg-7">
                                        <input type="text" id="BookTitle" class="form-control" value="" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-lg-2 control-label">ISBN 13</label>
                                    <div class="col-lg-7">
                                        <input type="text" id="ISBN13" class="form-control" value="" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-lg-2 control-label">ISBN 10</label>
                                    <div class="col-lg-7">
                                        <input type="text" id="ISBN10" class="form-control" value="" />
                                    </div>
                                </div>
                            </form>
						</div>
					</div>
				</div>
				<div class="widget-foot">
				</div>
			</div>
        </div>
	    <div class="col-lg-6 col-md-6">
	        <div class="widget wgreen">
			    <div class="widget-head">
                    Inventory
				</div>
				<div class="widget-content">
				    <div class="padd">
					<!--Form here-->
					    <div id="invresults">
                            <form class="form-horizontal" role="form">
                                <div class="form-group">
                                    <label class="col-lg-2 control-label">Inventory Count</label>
                                    <div class="col-lg-7">
                                        <input type="number" id="Inventory" class="form-control" />
                                    </div>
                                </div>
                            </form>
						</div>
					</div>
				</div>
				<div class="widget-foot">
				</div>
			</div>
        </div>
	</div>
	<div class="row">
	    <div class="col-lg-6 col-md-6">
	        <div class="widget wgreen">
			    <div class="widget-head">
                    Author Details
				</div>
				<div class="widget-content">
				    <div class="padd">
					<!--Form here-->
					    <div id="authresults">
                            <form class="form-horizontal" role="form">
                                <div class="form-group">
                                    <label class="col-lg-2 control-label">Select Author</label>
                                    <div class="col-lg-7">
                                        <select class="form-control" id="AuthorSel">

                                        </select>
                                    </div>
                                </div>
                                <p>or...</p>
                                <div class="form-group">
                                    <label class="col-lg-2 control-label">Enter Author</label>
                                    <div class="col-lg-7">
                                        <input type="text" id="AuthorEnter" class="form-control" value="" />
                                    </div>
                                </div>
                            </form>
						</div>
					</div>
				</div>
				<div class="widget-foot">
				</div>
			</div>
        </div>
	    <div class="col-lg-6 col-md-6">
	        <div class="widget wgreen">
			    <div class="widget-head">
                    Publisher Details
				</div>
				<div class="widget-content">
				    <div class="padd">
					<!--Form here-->
					    <div id="pubresults">
                            <form class="form-horizontal" role="form">
                                <div class="form-group">
                                    <label class="col-lg-2 control-label">Select Publisher</label>
                                    <div class="col-lg-7">
                                        <select class="form-control" id="PublisherSel">

                                        </select>
                                    </div>
                                </div>
                                <p>or...</p>
                                <div class="form-group">
                                    <label class="col-lg-2 control-label">Enter Publisher</label>
                                    <div class="col-lg-7">
                                        <input type="text" id="PublisherEnter" class="form-control" />
                                    </div>
                                </div>
                            </form>
						</div>
					</div>
				</div>
				<div class="widget-foot">
				</div>
			</div>
            <button class="btn btn-primary" onclick="AddNewBook();">Add Book</button>
        </div>
	</div>
</asp:Content>

