using DotNetCoreSqlDb.Controllers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace DotNetCoreSqlDb.Tests
{
    [TestClass]
    public class HomeControllerTests
    {
        [TestMethod]
        public void HomeController_Returns_Index_View()
        {
            // Arrange
            var controller = new HomeController();

            var result = controller.Index() as ViewResult;

            Assert.AreEqual("Index", result?.ViewName);
        }

        [TestMethod]
        public void HomeController_Returns_Privacy_View()
        {
            // Arrange
            var controller = new HomeController();

            var result = controller.Privacy() as ViewResult;

            Assert.AreEqual("Privacy", result?.ViewName);
        }

        [TestMethod]
        public void HomeController_Error_View_Throws_NullReferenceException_When_HttpContext_Is_Null()
        {
            var controller = new HomeController();

            Assert.ThrowsException<NullReferenceException>(() => controller.Error());
        }

    }
}