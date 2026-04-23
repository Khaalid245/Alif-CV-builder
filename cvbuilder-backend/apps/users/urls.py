"""
URL patterns for the users/auth app.
All routes are mounted under /api/v1/auth/ via config/api_router.py.
Token refresh is handled by simplejwt's built-in view.
"""
from django.urls import path
from .views import (
    RegisterView,
    LoginView,
    LogoutView,
    ProfileView,
    UpdateProfileView,
    ChangePasswordView,
    RequestDeletionView,
    TokenRefreshWrappedView,
)

urlpatterns = [
    path('register/',         RegisterView.as_view(),          name='auth-register'),
    path('login/',            LoginView.as_view(),              name='auth-login'),
    path('token/refresh/',    TokenRefreshWrappedView.as_view(), name='auth-token-refresh'),
    path('logout/',           LogoutView.as_view(),             name='auth-logout'),
    path('profile/',          ProfileView.as_view(),            name='auth-profile'),
    path('profile/update/',   UpdateProfileView.as_view(),      name='auth-profile-update'),
    path('change-password/',  ChangePasswordView.as_view(),     name='auth-change-password'),
    path('request-deletion/', RequestDeletionView.as_view(),    name='auth-request-deletion'),
]
