using FluentAssertions;
using Moq;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Features.Buses.Commands.CreateBus;
using SmartBus.Domain.Entities;

namespace SmartBus.Application.Tests.Features.Buses;

public class CreateBusCommandHandlerTests
{
    private readonly Mock<IUnitOfWork> _unitOfWorkMock;
    private readonly Mock<IBusRepository> _busRepositoryMock;
    private readonly CreateBusCommandHandler _handler;

    public CreateBusCommandHandlerTests()
    {
        _busRepositoryMock = new Mock<IBusRepository>();
        _unitOfWorkMock = new Mock<IUnitOfWork>();
        _unitOfWorkMock.Setup(u => u.Buses).Returns(_busRepositoryMock.Object);
        _unitOfWorkMock.Setup(u => u.SaveChangesAsync(It.IsAny<CancellationToken>())).ReturnsAsync(1);
        _handler = new CreateBusCommandHandler(_unitOfWorkMock.Object);
    }

    [Fact]
    public async Task Handle_ValidCommand_ShouldCreateBusAndReturnId()
    {
        // Arrange
        var command = new CreateBusCommand("ABC-123", "Mercedes Sprinter", 30, null);
        _busRepositoryMock
            .Setup(r => r.GetByPlateNumberAsync("ABC-123", It.IsAny<CancellationToken>()))
            .ReturnsAsync((Bus?)null);

        _busRepositoryMock
            .Setup(r => r.AddAsync(It.IsAny<Bus>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((Bus b, CancellationToken _) => b);

        // Act
        var result = await _handler.Handle(command, CancellationToken.None);

        // Assert
        result.IsSuccess.Should().BeTrue();
        result.Data.Should().NotBe(Guid.Empty);
        _busRepositoryMock.Verify(r => r.AddAsync(It.IsAny<Bus>(), It.IsAny<CancellationToken>()), Times.Once);
        _unitOfWorkMock.Verify(u => u.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task Handle_DuplicatePlateNumber_ShouldReturnFailure()
    {
        // Arrange
        var command = new CreateBusCommand("ABC-123", "Mercedes Sprinter", 30, null);
        _busRepositoryMock
            .Setup(r => r.GetByPlateNumberAsync("ABC-123", It.IsAny<CancellationToken>()))
            .ReturnsAsync(new Bus { PlateNumber = "ABC-123" });

        // Act
        var result = await _handler.Handle(command, CancellationToken.None);

        // Assert
        result.IsSuccess.Should().BeFalse();
        result.Error.Should().Contain("ABC-123");
        _busRepositoryMock.Verify(r => r.AddAsync(It.IsAny<Bus>(), It.IsAny<CancellationToken>()), Times.Never);
    }
}
