<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeFile="BookSearch.aspx.cs" Inherits="BookSearch" %>
<asp:Content ID="Content3" ContentPlaceHolderID="pagejs" Runat="Server">
    <script type="text/javascript">
        $(document).ready(function () {
            LoadBookList();
        });

        function LoadBookList() {
            var classId = $("#LoggedClassVal").val();
            var dataString = "{classId: '" + classId + "'}";
            $.ajax({
                type: "POST",
                url: "BookSearch.aspx/LoadBookList",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    if (resp == "X") {
                        alert("There was an error loading book list");
                    }
                    else {
                        if (resp != "0") {
                            var retObj = jQuery.parseJSON(resp);
                            $("#BookSelect").html("");
                            $("#BookSelect").append("<option value=''>Select...</option>");
                            $("#BookSelect").append("<option value='A'>ALL</option>");
                            $.each(retObj, function (key, value) {
                                var element = "<option value='" + value.Book_rid + "'>" + value.BookTitle + "</option>";
                                $("#BookSelect").append(element);
                            });
                        }
                    }
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax failure\nBOOOO \n" + exception);
                },
                async: false
            });
        }

        function GetBooks() {
            var classId = $("#LoggedClassVal").val();
            var bookName = $("#BookName").val();
            var bookSel = $("#BookSelect").val();
            var dataString = "{classId: '" + classId + "', bookName: '" + bookName + "', bookSel: '" + bookSel + "'}";

            $.ajax({
                type: "POST",
                url: "BookSearch.aspx/GetBooks",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    if (resp == "X") {
                        alert("There was an error searching book");
                    }
                    else {
                        $("#rsltTbl tbody").html("");
                        if (resp != "0") {                            
                            var retObj = jQuery.parseJSON(resp);

                            var elements = "";
                            $.each(retObj, function (key, value) {
                                var element = "";
                                element += "<tr>";
                                element += "<td>" + value.BookTitle + "</td>";
                                element += "<td>" + value.InventoryCount + "</td>";
                                element += "<td><button type='button' onclick='ShowEditBookModal(" + value.Book_rid + ");' class='btn btn-link'><i class='fa fa-pencil'></i></button></td>";
                                element += "</tr>";
                                elements += element;
                            });
                            $("#rsltTbl tbody").html(elements);
                        }
                    }
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax failure\nBOOOO \n" + exception);
                },
                async: false
            });
        }

        function ClearModalBook() {
            $("#BookModalName").val("");
            $("#BookModalYear").val("");
            $("#BookModalDescription").val("");
        }

        function LoadModalBook() {
            var bookId = $("#BookModalRid").val();
            var dataString = "{bookId: '" + bookId + "'}";

            $.ajax({
                type: "POST",
                url: "BookSearch.aspx/LoadModalBook",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    if (resp == "X") {
                        alert("There was an error loading book modal");
                    }
                    else {
                        if (resp != "0") {
                            var retObj = jQuery.parseJSON(resp);
                            $("#BookModalName").val(retObj["BookTitle"]);
                            $("#BookModalYear").val(retObj["YearPublished"]);
                            $("#BookModalDescription").val(retObj["BookDescription"]);
                        }
                    }
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax failure\nBOOOO \n" + exception);
                },
                async: false
            });
        }

        function ClearAuthorModal() {
            $("#CurAuthTbl tbody").html("");            
        }

        function LoadCurrentAuthor() {
            var bookId = $("#BookModalRid").val();
            var dataString = "{bookId: '" + bookId + "'}";

            $("#AuthorModalSel").html("");
            $.ajax({
                type: "POST",
                url: "BookSearch.aspx/LoadCurrentAuthor",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    if (resp == "X") {
                        alert("There was an error loading current authors");
                    }
                    else {
                        if (resp != "0") {
                            var retObj = jQuery.parseJSON(resp);
                            var elements = "";
                            $.each(retObj, function (key, value) {
                                var element = "";
                                element += "<tr>";
                                element += "<td>" + value.Name + "</td>";
                                element += "<td><button type='button' onclick='RemoveBookAuthor(" + value.rid + ");' class='btn btn-danger'>X</button></td>";
                                element += "</tr>";
                                elements += element;
                            });
                            $("#CurAuthTbl tbody").html(elements);
                        }
                    }
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax failure\nBOOOO \n" + exception);
                },
                async: false
            });
        }

        function LoadAuthorList() {
            $.ajax({
                type: "POST",
                url: "BookSearch.aspx/LoadAuthorList",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    if (resp == "X") {
                        alert("There was an error loading author list");
                    }
                    else {
                        $("#AuthorModalSel").html("");
                        $("#AuthorModalSel").append("<option value=''>Select...</option>");
                        if (resp != "0") {
                            var retObj = jQuery.parseJSON(resp);
                            $.each(retObj, function (key, value) {
                                var element = "<option value='" + value.rid + "'>" + value.Name + "</option>";
                                $("#AuthorModalSel").append(element);
                            });
                        }
                    }
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax failure\nBOOOO \n" + exception);
                },
                async: false
            });
        }

        function SaveBookUpdate() {
            var bookId = $("#BookModalRid").val();            
            var bookName = $("#BookModalName").val().replace(/'/gi,"`");
            var bookYear = $("#BookModalYear").val().replace(/'/gi,"`");
            var bookDesc = $("#BookModalDescription").val().replace(/'/gi,"`");

            if (bookName == "") {
                alert("The book needs a title");
                return;
            }

            var dataString = "{bookId: '" + bookId + "', bookName: '" + bookName + "', bookYear: '" + bookYear + "', bookDesc: '" + bookDesc + "'}";
            $.ajax({
                type: "POST",
                url: "BookSearch.aspx/SaveBookUpdate",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    if (resp == "X") {
                        alert("There was an error upating book");
                    }
                    else {
                        ClearModalBook();
                        LoadModalBook();
                        GetBooks();
                        alert("Updated!");
                    }
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax failure\nBOOOO \n" + exception);
                },
                async: false
            });
        }

        function RemoveBookAuthor(rid) {
            var dataString = "{bookAuthId: '" + rid + "'}";
            $.ajax({
                type: "POST",
                url: "BookSearch.aspx/RemoveBookAuthor",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    if (resp == "X") {
                        alert("There was an error removing author");
                    }
                    else {
                        ClearAuthorModal();
                        LoadCurrentAuthor();
                    }
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax failure\nBOOOO \n" + exception);
                },
                async: false
            });
        }

        function AddNewModalAuthor() {
            var bookId = $("#BookModalRid").val();
            var authId = $("#AuthorModalSel").val();

            if (authId == "") {
                alert("Please select author");
                return;
            }

            var dataString = "{bookId: '" + bookId + "', authId: '" + authId + "'}";
            $.ajax({
                type: "POST",
                url: "BookSearch.aspx/AddBookAuthor",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    if (resp == "X") {
                        alert("There was an error adding author");
                    }
                    else {
                        ClearAuthorModal();
                        LoadCurrentAuthor();
                    }
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax failure\nBOOOO \n" + exception);
                },
                async: false
            });
        }

        function ClearInventory() {
            $("#CurInvTbl tbody").html("");
        }

        function LoadInventory() {
            var classId = $("#LoggedClassVal").val();
            var bookId = $("#BookModalRid").val();
            var dataString = "{bookId: '" + bookId + "', classId: '" + classId + "'}";
            $.ajax({
                type: "POST",
                url: "BookSearch.aspx/LoadInventory",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    if (resp == "X") {
                        alert("There was an error loading inventory");
                    }
                    else {
                        ClearInventory();
                        if (resp != "0") {
                            var retObj = jQuery.parseJSON(resp);
                            var elements = "";
                            $.each(retObj, function (key, value) {
                                var element = "";
                                element += "<tr>";
                                element += "<td>" + value.rid + "</td>";
                                element += "<td><button class='btn btn-danger' onclick=RetireInventory('" + value.rid + "');>X</button>";
                                element += "</tr>";
                                elements += element;
                            });
                            $("#CurInvTbl tbody").html(elements);
                        }
                    }
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax failure\nBOOOO \n" + exception);
                },
                async: false
            });
        }

        function RetireInventory(rid) {
            if (confirm("Are you positive?")) {
                var dataString = "{invId: '" + rid + "'}";
                $.ajax({
                    type: "POST",
                    url: "BookSearch.aspx/RetireInventory",
                    data: dataString,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) {
                        var resp = msg.d;
                        if (resp == "X") {
                            alert("There was an error retiring inventory");
                        }
                        else {
                            ClearInventory();
                            LoadInventory();
                            GetBooks();
                            alert("Updated");
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, exception) {
                        alert("Ajax failure\nBOOOO \n" + exception);
                    },
                    async: false
                });
            }
        }

        function CloseBookModal() {
            $("#BookModalRid").val("");
            ClearModalBook();
            ClearAuthorModal();
            $("#BookModal").modal("hide");
        }

        function ShowEditBookModal(rid) {
            $("#BookModalRid").val(rid);

            ClearModalBook();
            LoadModalBook();

            ClearAuthorModal();
            LoadCurrentAuthor();
            LoadAuthorList();

            ClearInventory();
            LoadInventory();

            $("#BookModal").modal("show");
        }
    </script>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="pagetitle" Runat="Server">
    <h2 class="pull-left"><i class="fa fa-book"></i> Search Books</h2>
    <div class="clearfix"></div>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <div class="row">
	    <div class="col-lg-4 col-md-4">
		    <div class="widget wgreen">
			    <div class="widget-head">
				    <div class="pull-left">Book Search</div>
		            <div class="widget-icons pull-right">
		                <i class="fa fa-search"></i>
		            </div>
		            <div class="clearfix"></div>
				</div>
				<div class="widget-content">
				    <div class="padd">
					    <!--Form here-->
				        <form role="form">
				            <div class="form-group">
					            <label>Book Name</label>
                                <input type="text" id="BookName" class="form-control" placeholder="book name..." />
				            </div>
                            <div class="form-group">
                                <label>or...</label>
                            </div>
				            <div class="form-group">
					            <label>Select Book</label>
                                <select id="BookSelect" class="form-control">
                                </select>
				            </div>
				            <div class="form-group">				                
				                <button type="button" id="btn" onclick="GetBooks();" class="btn btn-primary">Submit</button>
				            </div>
				        </form>
					</div>
				</div>
				<div class="widget-foot">
				</div>
			</div>
	    </div>
	    <div class="col-lg-8 col-md-8">	            	
		    <div class="widget wgreen">
			    <div class="widget-head">
                    Results
				</div>						
				<div class="widget-content">
				    <div class="padd">
					    <!--Form here-->
						<div id="rslts">
						    <table class="table table-hover" id="rsltTbl">
							    <thead>
								    <tr>
									    <th>Book Name</th>
										<th>Inventory Amt.</th>
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
    <div id="BookModal" class="modal fade" role="dialog">
		<div class="modal-dialog modal-lg">
			<div class="modal-content">
	            <div class="modal-header">
	                <button type="button" class="close btn btn-sm btn-primary" onclick="CloseBookModal();">X</button>
	                <input type="hidden" id="BookModalRid" value="" />
	                <h4 class="modal-title">Edit Book</h4>
	            </div>
	            <div class="modal-body">
	                <div class="ModMain">
	                	<div class="row">
	                		<div class="col-lg-8 col-md-8">
	                			<div class="panel panel-default">
	                				<div class="panel-heading">
	                					Book Details
	                				</div>
	                				<div class="panel-body">
							            <form role="form">
							            	<div class="form-group">
								            	<label>Book Name</label>
                                                <input type="text" id="BookModalName" class="form-control" />
							            	</div>
							            	<div class="form-group">
								            	<label>Year</label>
                                                <input type="text" id="BookModalYear" class="form-control" />
							            	</div>
							            	<div class="form-group">
								            	<label>Description</label>
                                                <textarea id="BookModalDescription" class="form-control" rows="5"></textarea>
							            	</div>
							            	<div class="form-group">
                                                <button type="button" class="btn btn-primary" onclick="SaveBookUpdate();">Save</button>					            		
							            	</div>	
							            </form>
						            </div>
					            </div>
	                		</div>
                            <div class="col-lg-4 col-md-4">
	                			<div class="panel panel-default">
	                				<div class="panel-heading">
	                					Inventory
	                				</div>
	                				<div class="panel-body">
									    <table class="table table-hover" id="CurInvTbl">
										    <thead>
											    <tr>
												    <th>ID</th>
													<th>Retire</th>
												</tr>
											</thead>
											<tbody>
															
											</tbody>
										</table> 
						            </div>
					            </div>
                            </div>
	                	</div> 
	                	<div class="row">
	                		<div class="col-lg-12 col-md-12">
								<div class="panel panel-default">
	                				<div class="panel-heading">
	                					Author Details
	                				</div>
	                				<div class="panel-body">
	                					<div class="col-lg-6 col-md-6">
	                						<div class="panel panel-default">
	                							<div class="panel-heading">
	                								Current
	                							</div>
	                							<div class="panel-body">
													<table class="table table-hover" id="CurAuthTbl">
														<thead>
															<tr>
																<th>Name</th>
																<th>Remove</th>
															</tr>
														</thead>
														<tbody>
																
														</tbody>
													</table>         									
	                							</div>
	                						</div>
	                					</div>
	                					<div class="col-lg-6 col-md-6">
	                						<div class="panel panel-default">
	                							<div class="panel-heading">
	                								Add Author
	                							</div>
	                							<div class="panel-body">
	                								<form role="form">
										            	<div class="form-group">
											            	<label>Select Author</label>
                                                            <select id="AuthorModalSel" class="form-control">

                                                            </select>
										            	</div>
										            	<div class="form-group">
											            	<button type="button" class="btn btn-primary" onclick="AddNewModalAuthor();">Add</button>
										            	</div>
	                								</form>
	                							</div>
	                						</div>
	                					</div>
	                				</div>
	                			</div>
	                		</div>
	                	</div>
	                </div>
	            </div>
	            <div class="modal-footer">
	                <button type="button" class="btn btn-danger" onclick="CloseBookModal();">Close</button>                	
	            </div>
	        </div>
		</div>
	</div>
</asp:Content>
