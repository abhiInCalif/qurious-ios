# Create your views here.

from django.views.generic import View
from django.http import HttpResponse
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, login, logout
from qurious.profiles.models import UserProfile, Skill
from qurious.auth.forms import ProfileSignUpForm
from django.utils import simplejson

class QuriousLoginView(View):
    """
    This is the view to log in a user
    """
    def post(self, request, *args, **kwargs):
        username = request.POST.get('username')
        password = request.POST.get('password')
        user = authenticate(username=username, password=password)

        if user is not None:
            login(request, user)
	        data = simplejson.dumps({'userid': user.id})
            return HttpResponse(data, mimetype='application/json')
        else:
            return HttpResponse('', mimetype='application/json')

class QuriousLogoutView(View):
    """
    this is the view to for a user to log out
    """
    def post(self, request, *args, **kwargs):
        logout(request)
        data = simplejson.dumps({'return':'1'})
        return HttpResponse(data, mimetype='application/json')
        

class QuriousSignUpView(View):
    """
    This is a view for a user to sign up. Takes in an email, username, and password
    """
    def post(self, request, *args, **kwargs):
        form = ProfileSignUpForm(request.POST)
        if form.is_valid():
            try:
                user = User.objects.get(username=form.cleaned_data.get('username'))
                data = simplejson.dumps({'return':'0'})
                return HttpResponse(data, mimetype='application/json')
            except:
                user_dummy = User(username=form.cleaned_data.get('username'), email=form.cleaned_data.get('user_email'))
                user_dummy.set_password(form.cleaned_data.get('password'))
                user_dummy.save()
                user_dummy_profile = UserProfile(user=user_dummy, profile_name=user_dummy.username, user_email=user_dummy.email, user_bio='')
            
                s = Skill(name='learning', desc='I like to learn!', price=0, is_marketable=False)
                user_dummy_profile.save()
                s.save()
                user_dummy_profile.skills.add(s)
                user_dummy_profile.save()
                
                data = simplejson.dumps({'return':'1'})
                return HttpResponse(data, mimetype='application/json')
        else:
            return HttpResponse('', mimetype='application/json')
