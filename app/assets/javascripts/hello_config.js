hello.init({
  marktplaats: ""
});


hello().login().then(function() {
    alert('You are signed in to Facebook');
}, function(e) {
    alert('Signin error: ' + e.error.message);
});
