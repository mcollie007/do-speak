# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
`
$(function () {
 // $('[data-toggle="tooltip"]').tooltip();
});

var template = function(text, task_id) {
  return '<p id="task-'+task_id+'" data-task-id="'+task_id
  +'" data-task-status="false"><input type="checkbox" id="status"><i class="glyphicon glyphicon-star"></i><span><a href="/tasks/'
  +task_id+ '">' + text + '</a></span><i class="glyphicon glyphicon-remove active"></i></p>';
};

var voiceText = function(text){
    $('.voice-text').fadeIn('fast');
    $('.voice-text').html('<p>'+text+'</p>');
    $('.voice-text').fadeOut(3000);
};


var main = function() {
    
    var task_id = $('#task').data('taskId');
    
    //add item to list
    var add = function(term){
    
        var note = "";
        var done = false;
        var time = Date.now();
        var results = { task: { item: ''+term+'', note: ''+note+'', done: ''+done+'', time: ''+time+'' }};
        voiceText(term);
        $.post('/tasks', results, function(){
            pullId(term);
            //getId(term, "add");
        });
            
        
    }; 
    
    //remove item from list
    var remove = function(term){
        voiceText(term);
        $.getJSON('tasks.json', function(data){
            console.log(term);
            console.log(data);
           
            $.each(data, function(index){
                //var html = template_list(data[index].item, data[index].id);
                //$(html).appendTo('ul.lists');
                if(term === data[index].item){
                 
                    $.ajax('tasks/'+data[index].id, {
                        type: "post",
                        dataType: "json",
                        data: { "_method":"delete"},
                        success: function(){
                            alert("Are you sure you want to delete "+ term +"?");
                            $('.list').find('#task-'+data[index].id+'').remove();
                        } 
        
                    });
                }
            });
       });
    };
    
    //label item as done
    var finish = function(term){
        //getId(term, "finish");
        voiceText(term);
        $.getJSON('tasks.json', function(data){
            console.log(term);
            console.log(data);
           
            $.each(data, function(index){
                
                var tlist = $('.list').find('#task-'+data[index].id+'');
                if(term === data[index].item){
                    $(tlist).find('.glyphicon-star').addClass('active');
                    $.ajax('tasks/'+data[index].id, {
                        type: "put",
                        dataType: "json",
                        data: { task: { done: true }},
                        success: function(){
                            //alert("task done");
                            //$(tlist).data('taskStatus') === true;
                            
                            console.log($(this).data('taskStatus') );
                        } 
        
                    });
                }
            });
       });
        
    };
    
    //unlabel item as done
    var begin = function(term){
        //getId(term, "begin");
        voiceText(term);
        $.getJSON('tasks.json', function(data){
            console.log(term);
            console.log(data);
           
            $.each(data, function(index){
                //var html = template_list(data[index].item, data[index].id);
                //$(html).appendTo('ul.lists');
                var tlist = $('.list').find('#task-'+data[index].id+'');
                if(term === data[index].item){
                 
                    $.ajax('tasks/'+data[index].id, {
                        type: "put",
                        dataType: "json",
                        data: { task: { done: false }},
                        success: function(){
                            //alert("task not done");
                           
                            $(tlist).find('.glyphicon-star').removeClass('active');
                            console.log($(this).data('taskStatus') );
                        } 
        
                    });
                }
            });
       });
    };
    
    //show item
    var show = function(term){
        
        voiceText(term);
        $.getJSON('tasks.json', function(data){
            
            $.each(data, function(index){
                if(term === data[index].item){
                    location.href = "/tasks/"+data[index].id;
                }
            });
        });
    };
    
    //load to home page using voice controls
    var load = function(term){
        
        switch(term){
        
            case "home": 
                location.href = "/";
            break;
            case "help":
                location.href = "/help/index";
            break;
            default:
                location.href = "/";
        }
    };
    
    //edits task title (:item) on show.html using voice controls
    var editItem = function(term){
    
        voiceText(term);
        var $tid = $('#note').data('noteId');
        $('#edit-task').text(term);
        
        $.ajax('/tasks/'+$tid, {
            type: "put",
            dataType: "json",
            data: { task: { item: ''+term+'' }},
            success: function(){
                    
                       
                //$('#task-form').hide();
               // $('#task').fadeIn('fast');
                        
            } 
                
        });
    };
    
    //edits task note (:note) on show.html using voice controls
    var editNote = function(term){
    
        voiceText(term);
        var $tid = $('#note').data('noteId');
        $('#edit-note').text(term);
        
        $.ajax('/tasks/'+$tid, {//tasks
            type: "put",
            dataType: "json",
            data: { task: { note: ''+term+'' }},
            success: function(){
                 
                $('#note-form').hide();
                $('#note').fadeIn('fast');
              
            } 
            
        });
    };
    
    
    //helper to add id to markup
    var pullId = function(term){
        $.getJSON('tasks.json', function(data){
            console.log(data);
            $.each(data, function(index){
                if(term === data[index].item){
                    var tid = data[index].id;
                    var html = template(term, tid);
            
                    $(html).appendTo('.list');
                    console.log(html);
                }
            });
        });
    };
 
   if(annyang){
        var words = {
            'add *term': add,
            'remove *term': remove,
            'finish *term': finish,
            'begin *term': begin,
            'show *term': show,
            'load *term': load,
            'item *term': editItem,
            'note *term': editNote,
        };  
    
        annyang.addCommands(words);
        annyang.debug();
        annyang.start();

    }
         
    $('form.new_task').submit(function() {
        var todo = $('#todo');
            if(todo.val() !== ""){
                var note = "";
                var done = false;
                var time = Date.now();
                var results = { task: { item: ''+todo.val()+'', note: ''+note+'', done: ''+done+'', time: ''+time+'' }};
                $.post('/tasks', results, function(){
                    //var html = template(todo.val(), task_id);
                    //$(html).appendTo('.list');
                    pullId(todo.val() );
                    //getId(todo.val(), "add");
                    $(todo).val("");
                });
            }
          
        return false;
    });
   
    $(document).on("click", '.glyphicon-star', function(){
        $tid = $(this).parent().data('taskId');
        //var task_status = $(this).parent().data('taskStatus');
        console.log($tid);
        //console.log(task_status);
        $(this).toggleClass('active');
        $.get('tasks/'+$tid+'.json', function(data){
        
        console.log(data.done);
        if( data.done === true ){
            $('#task-'+tid+'').find('span').removeClass('.done');//({"text-decoration":"none", "color":"#473e39"});
            //$(this).addClass('active');
            $.ajax('tasks/'+$tid, {
                    type: "put",
                    dataType: "json",
                    data: { task: { done: "false" }},
                    success: function(){
                        //alert("task not done");
                        
                    } 
            
            });
            
        }else{
            $('#task-'+tid+'').find('span').addClass('.done');//({"text-decoration":"line-through", "color":"silver"});
            //$(this).removeClass('active');
            $.ajax('tasks/'+$tid, {
                    type: "put",
                    dataType: "json",
                    data: { task: { done: "true" }},
                    success: function(){
                        //alert("task done");
                        
                    } 
            
            });
        }
        
        //
        });
        
    });
    
    $(document).on("click", '.glyphicon-remove', function(){
        $(this).parent().remove();    
        var tid = $(this).parent().data('taskId');
        //var term = $('#task-'+tid+'').find('a').html();
        //console.log(term);
        $.ajax('tasks/'+tid, {
                type: "post",
                dataType: "json",
                data: { "_method":"delete"},
                success: function(){
                     //$(this).parent().remove();  
                     // alert("Are you sure you want to delete "+ term +"?");
                     alert("Are you sure?");
                     //$('.list').find('#task-'+data[index].id+'').remove();
                } 
        
        });
    });
    
    /**
        ajax functions to edit the task item
    */
    $('#edit-task').click(function(){
        $('#task').hide();
        $('#task-form').fadeIn("slow");
    });
 
    $('#task-form').submit(function(){
        
        var item = $('#todo-task');
        var $tid = $('#note').data('noteId');
        
        if( item.val() !== ""){
            $('#edit-task').text(item.val());
             $.ajax('/tasks/'+$tid, {
                    type: "put",
                    dataType: "json",
                    data: { task: { item: ''+item.val()+'' }},
                    success: function(){
                    
                        //console.log(item.val());
                        //$('#notice').text("Task updated!");
                        //$('#notice').fadeIn('slow');
                       
                        $('#task-form').hide();
                        $('#task').fadeIn('fast');
                        
                        
                         //$(task).val("");
                        //$('#notice').text("");
                        //$('#notice').fadeOut('slow');
                        
                        //alert("Note updated!");
                    } 
                
            });
        } else {
            $('#task-form').hide();
            $('#task').fadeIn('fast');
        }
    });
    
    /**
        ajax functions to edit the task note
    */
    
    $('#edit-note').click(function(){
        $('#note').hide();
        $('#note-form').fadeIn("slow");
    });
    
    $('#note-form').submit(function(){
    
        var note = $('#todo-note');
        var $tid = $('#note').data('noteId');
        if( note.val() !== ""){
             $('#edit-note').text(note.val());
             $.ajax('/tasks/'+$tid, {//tasks
                    type: "put",
                    dataType: "json",
                    data: { task: { note: ''+note.val()+'' }},
                    success: function(){
                    
                       // $('#notice').text("Note updated!");
                        //$('#notice').show();
                        
                        $('#note-form').hide();
                        $('#note').fadeIn('fast');
                        
                        //$('#notice').text("");
                        //$('#notice').fadeOut('slow');
                    } 
            
            });
        }else{
            $('#note-form').hide();
            $('#note').fadeIn('fast');
        }
    }); 
 
};


$(document).ready(main);
`

`
/*
var template_list = function(text, task_id) {
  return '<li id="task" data-task-id="'+task_id+'" data-task-status="false"><input type="checkbox" id="status"><i class="glyphicon glyphicon-star"></i><span>' + text + '</span><i class="glyphicon glyphicon-remove"></i></li>';
};

var demo = function() {
    var task_id = $('#task').data('taskId');
    var task_status = $('#task').data('taskStatus');
    
    var taskItem, taskId, taskNote, taskDone, taskTime;
   $.getJSON('tasks.json', function(data){
        console.log(data);
        $.each(data, function(index){
             var html = template_list(data[index].item, data[index].id);
             $(html).appendTo('ul.lists');
        });
   });
   
    var render = function(){
        $.getJSON('tasks.json', function(data){
        console.log(data);
            $.each(data, function(index){
                 var html = template_list(data[index].item, data[index].id);
                 $(html).appendTo('ul.lists');
            });
        });
    };
    
    var added = function(term){
    
        var note = "";
        var done = false;
        var time = Date.now();
        var results = { task: { item: ''+term+'', note: ''+note+'', done: ''+done+'', time: ''+time+'' }};
        
        $.post('/tasks', results, function(){
            var html = template_list(term, "");
            $(html).appendTo('ul.lists');
            render();
        });
            
        
    }; 
    
  
   if(annyang){
        var words = {
            'add *term': added,
            //'remove *term': remove,
            //'finish *term': finish,
        };  
    
        annyang.addCommands(words);
        annyang.start();

    }

};
$(document).ready(demo);*/
`
`
/**    
   var getId = function(term, action){
        $.getJSON('tasks.json', function(data){
            $.each(data, function(index){
                if(term === data[index.item]){
                    var tid = data[index].id;
                    //var status = data[index].done;
                    var word = term;
                    switch(action){
                        case 'add':
                            var html = template(word, tid);
            
                            $(html).appendTo('.list');
                            break;
                        case 'remove':
                            $.ajax('tasks/'+data[index].id, {
                                type: "post",
                                dataType: "json",
                                data: { "_method":"delete"},
                                success: function(){
                                    alert("deleted "+ word);
                                    $('.list').find('#task-'+data[index].id+'').remove();
                                } 
                
                            });
                            break;
                        case 'finish':
                            taskChange(true, tid);
                            break;
                        case 'begin':
                            taskChange(false, tid);
                            break;
                            
                    }
                
                
                }
            });
        
        });
   }
   
   var taskChange = function(status, tid){
        var tlist = $('.list').find('#task-'+tid+'');
        if( status === true ){ //if status of task = true, change task to true
            
            $.ajax('tasks/'+$tid, {
                    type: "put",
                    dataType: "json",
                    data: { task: { done: true }},
                    success: function(){
                        alert("task done");
                        $(tlist).data('taskStatus') === true;
                        $(tlist).find('.glyphicon-star').addClass('active');
                        console.log($(this).data('taskStatus') );
                    } 
            
            });
            
           
            
        }else{
        
            
            $.ajax('tasks/'+$tid, {
                    type: "put",
                    dataType: "json",
                    data: { task: { done: false }},
                    success: function(){
                        alert("task not done");
                        $(tlist).data('taskStatus') === false;
                        $(tlist).find('.glyphicon-star').removeClass('active');
                        console.log($(list).data('taskStatus') );
                        
                     
                    } 
            
            });
        }
        
        //});
   }; */`
   